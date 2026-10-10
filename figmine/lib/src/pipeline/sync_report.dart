import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/figma/figma_version.dart';
import 'package:figmine/src/lock/diff_report.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/token_diff.dart';
import 'package:figmine/src/pipeline/sync_analyzer.dart';

/// Builds the pull request report of a sync.
abstract final class SyncReport {
  /// The Markdown report of [analysis] against [previous].
  static String of({
    required FigmaFileMeta meta,
    required LockFile? previous,
    required SyncAnalysis analysis,
    required TokenDiff diff,
    required List<FigmaVersion> versions,
  }) => DiffReport.markdown(
    fileName: meta.name,
    previous: previous,
    next: analysis.lock,
    diff: diff,
    versions: versions,
    audit: analysis.audit,
    migration: analysis.migration,
    fonts: analysis.fonts,
  );
}
