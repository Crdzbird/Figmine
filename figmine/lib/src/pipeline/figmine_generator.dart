import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/lock/accessibility_section.dart';
import 'package:figmine/src/lock/token_diff.dart';
import 'package:figmine/src/migrate/code_migrator.dart';
import 'package:figmine/src/pipeline/generate_outcome.dart';
import 'package:figmine/src/pipeline/generate_status.dart';
import 'package:figmine/src/pipeline/output_writer.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/sync_analyzer.dart';
import 'package:figmine/src/pipeline/sync_report.dart';
import 'package:figmine/src/pipeline/token_fetcher.dart';

/// Fetches tokens from Figma and rewrites the generated files on change.
final class FigmineGenerator {
  /// Creates a generator.
  const factory({
    required FigmineConfig config,
    required TokenFetcher fetcher,
    required ProjectFiles files,
    required ProjectInfo project,
    required void Function(String message) log,
    bool format,
    bool migrate,
  }) = FigmineGenerator._;

  const new _({
    required this.config,
    required this.fetcher,
    required this.files,
    required this.project,
    required this.log,
    this.format = true,
    this.migrate = true,
  });

  /// The project configuration.
  final FigmineConfig config;

  /// Reads tokens from Figma.
  final TokenFetcher fetcher;

  /// Reads and writes project files.
  final ProjectFiles files;

  /// Facts about the project that shape the generated code.
  final ProjectInfo project;

  /// Receives progress messages.
  final void Function(String message) log;

  /// Whether to run `dart format` on the generated code.
  final bool format;

  /// Whether to rewrite renamed tokens in the project's code.
  final bool migrate;

  /// Runs the sync; [force] rewrites files even without changes.
  Future<GenerateOutcome> run({bool force = false}) async {
    final previous = await files.readLock(config.lockFile);
    final meta = await fetcher.meta();
    log('Figma file ${meta.label}.');
    if (!force && previous?.version == meta.version) {
      return const GenerateOutcome(status: GenerateStatus.upToDate);
    }
    final tokens = await fetcher.fetch(meta);
    final migrator = migrate
        ? CodeMigrator(root: files.root, output: config.output.directory)
        : null;
    final analysis = await SyncAnalyzer.analyze(
      config: config,
      tokens: tokens,
      project: project,
      previous: previous,
      migrator: migrator,
    );
    AccessibilitySection.log(analysis.audit).forEach(log);
    final diff = TokenDiff.between(previous, analysis.lock);
    final report = SyncReport.of(
      meta: meta,
      previous: previous,
      analysis: analysis,
      diff: diff,
      versions: diff.isEmpty || previous == null
          ? const []
          : await fetcher.versions(previous.version),
    );
    if (!force && previous != null && diff.isEmpty) {
      return GenerateOutcome(status: GenerateStatus.unchanged, report: report);
    }
    await OutputWriter(
      config: config,
      files: files,
      project: project,
      log: log,
      format: format,
    ).write(tokens, analysis, migrator: migrator);
    return GenerateOutcome(status: GenerateStatus.updated, report: report);
  }
}
