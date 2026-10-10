import 'package:figmine/src/codegen/code_emitter.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/lock/font_section.dart';
import 'package:figmine/src/lock/lock_json.dart';
import 'package:figmine/src/migrate/code_migrator.dart';
import 'package:figmine/src/naming/token_naming.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/pipeline/stale_files.dart';
import 'package:figmine/src/pipeline/sync_analyzer.dart';
import 'package:figmine/src/tokens/token_set.dart';
import 'package:path/path.dart' as p;

/// Writes the generated code, icons and lock file of a sync.
final class OutputWriter {
  /// Creates a writer for the project behind [files].
  const factory({
    required FigmineConfig config,
    required ProjectFiles files,
    required ProjectInfo project,
    required void Function(String message) log,
    bool format,
  }) = OutputWriter._;

  const new _({
    required this.config,
    required this.files,
    required this.project,
    required this.log,
    this.format = true,
  });

  /// The project configuration.
  final FigmineConfig config;

  /// Reads and writes project files.
  final ProjectFiles files;

  /// Facts about the project that shape the generated code.
  final ProjectInfo project;

  /// Receives progress messages.
  final void Function(String message) log;

  /// Whether to run `dart format` on the generated code.
  final bool format;

  /// Writes [tokens] as code, removes stale files, and stores the lock.
  ///
  /// Constants deprecated in the lock of [analysis] are written next to
  /// the live ones, and [migrator] rewrites the code using renamed symbols.
  Future<void> write(
    TokenSet tokens,
    SyncAnalysis analysis, {
    CodeMigrator? migrator,
  }) async {
    final lock = analysis.lock;
    FontSection.log(analysis.fonts).forEach(log);
    final renamed = analysis.migration.renamed;
    final rewritten = await migrator?.rewrite(renamed) ?? const {};
    if (rewritten.isNotEmpty) log('Renamed tokens in ${rewritten.join(', ')}.');
    final code = CodeEmitter.emit(
      config: config,
      tokens: tokens,
      project: project,
      deprecated: lock.deprecated,
    );
    await files.writeAll(code);
    final stale = await StaleFiles.prune(files.root, config.output.directory, {
      for (final file in code) p.normalize(file.path),
    });
    if (stale.isNotEmpty) log('Removed ${stale.join(', ')}.');
    await _writeIcons(TokenNaming.icons(tokens.icons));
    await files.writeText(config.lockFile, LockJson.encode(lock));
    if (!format) return;
    final error = await files.format(config.output.directory);
    if (error != null) log('dart format failed: $error');
  }

  Future<void> _writeIcons(List<NamedIcon> icons) async {
    final iconsConfig = config.icons;
    if (iconsConfig == null) return;
    await files.syncIcons(iconsConfig.output, icons);
    if (await files.declaresAssets(iconsConfig.output)) return;
    log('Add "${iconsConfig.output}/" to flutter.assets in pubspec.yaml.');
  }
}
