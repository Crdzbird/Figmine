import 'dart:io';

import 'package:path/path.dart' as p;

/// Renders the preview images as a Markdown table for the report.
abstract final class PreviewSection {
  /// The section for images in [after], compared with [before] when its
  /// images exist. Paths are relative to [root]; [base] prefixes links.
  static String markdown({
    required String root,
    required String after,
    String? before,
    String? base,
  }) {
    String image(String folder, String mode) {
      final path = p.posix.joinAll(p.split(p.join(folder, '$mode.png')));
      final url = base == null ? path : '$base/$path?raw=true';
      return '<img src="$url" width="420" alt="$mode">';
    }

    bool exists(String? folder) =>
        folder != null && File(p.join(root, folder, 'light.png')).existsSync();
    final compare = exists(before);
    final buffer = StringBuffer()
      ..writeln('### Preview')
      ..writeln()
      ..writeln(compare ? '| | Before | After |' : '| | After |')
      ..writeln(compare ? '| --- | --- | --- |' : '| --- | --- |');
    for (final mode in const ['light', 'dark']) {
      final cells = [if (compare) image(before!, mode), image(after, mode)];
      buffer.writeln(
        '| ${mode[0].toUpperCase()}${mode.substring(1)} | '
        '${cells.join(' | ')} |',
      );
    }
    return (buffer..writeln()).toString();
  }

  /// Link base for images pushed to [branch] of the GitHub repository the
  /// workflow runs in, or null outside GitHub Actions.
  static String? githubBase(String branch) {
    final env = Platform.environment;
    final repository = env['GITHUB_REPOSITORY'];
    if (repository == null || repository.isEmpty) return null;
    final server = env['GITHUB_SERVER_URL'] ?? 'https://github.com';
    return '$server/$repository/blob/$branch';
  }
}
