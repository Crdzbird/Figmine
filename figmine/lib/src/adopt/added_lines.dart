import 'dart:io';

import 'package:figmine/src/adopt/adopt_project.dart';
import 'package:figmine/src/config/config_exception.dart';

/// Reads which lines a branch adds, from `git diff`.
abstract final class AddedLines {
  static final RegExp _file = RegExp(r'^\+\+\+ b/(.+)$');

  static final RegExp _hunk = RegExp(r'^@@ -\S+ \+(\d+)(?:,(\d+))? @@');

  /// The lines added since the merge base with [ref], by file path relative
  /// to [root], within [paths].
  static Future<Map<String, Set<int>>> since(
    String root,
    String ref,
    List<String> paths,
  ) async {
    final result = await Process.run('git', [
      'diff',
      '-U0',
      '--no-color',
      '$ref...HEAD',
      '--',
      ...paths,
    ], workingDirectory: root);
    if (result.exitCode != 0) {
      throw ConfigException('git diff against $ref failed: ${result.stderr}');
    }
    return parse('${result.stdout}');
  }

  /// [files] with only the values on [added] lines.
  static List<AdoptFile> keep(
    List<AdoptFile> files,
    Map<String, Set<int>> added,
  ) => [
    for (final file in files)
      if (added[file.path] case final lines?)
        if ([
              for (final s in file.found)
                if (lines.contains(s.literal.line)) s,
            ]
            case final found when found.isNotEmpty)
          (path: file.path, source: file.source, found: found),
  ];

  /// The added lines of a unified [diff] with no context lines.
  static Map<String, Set<int>> parse(String diff) {
    final added = <String, Set<int>>{};
    Set<int>? current;
    for (final line in diff.split('\n')) {
      final file = _file.firstMatch(line);
      if (file != null) current = added[file.group(1)!] = {};
      final hunk = _hunk.firstMatch(line);
      if (hunk == null || current == null) continue;
      final start = int.parse(hunk.group(1)!);
      final count = int.parse(hunk.group(2) ?? '1');
      current.addAll([for (var i = 0; i < count; i++) start + i]);
    }
    return added;
  }
}
