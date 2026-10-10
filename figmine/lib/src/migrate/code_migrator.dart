import 'dart:io';

import 'package:path/path.dart' as p;

/// Finds and rewrites uses of generated symbols in the project's Dart code.
final class CodeMigrator {
  /// Creates a migrator over the source folders of [root], skipping the
  /// generated [output] folder.
  const factory({
    required String root,
    required String output,
    List<String> folders,
  }) = CodeMigrator._;

  const new _({
    required this.root,
    required this.output,
    this.folders = const ['lib', 'test', 'integration_test', 'bin'],
  });

  /// Project folder.
  final String root;

  /// Generated folder, relative to [root], never scanned.
  final String output;

  /// Folders, relative to [root], that are scanned.
  final List<String> folders;

  /// Files, relative to [root], that use each of [symbols].
  Future<Map<String, Set<String>>> usages(Iterable<String> symbols) async {
    final found = <String, Set<String>>{};
    final patterns = {for (final s in symbols) s: _pattern(s)};
    if (patterns.isEmpty) return found;
    await for (final (path, text) in _sources()) {
      for (final entry in patterns.entries) {
        if (!entry.value.hasMatch(text)) continue;
        found.putIfAbsent(entry.key, () => {}).add(path);
      }
    }
    return found;
  }

  /// Replaces each old symbol of [renamed] with its new name. Returns the
  /// rewritten files.
  Future<Set<String>> rewrite(Map<String, String> renamed) async {
    final changed = <String>{};
    if (renamed.isEmpty) return changed;
    await for (final (path, text) in _sources()) {
      var next = text;
      for (final entry in renamed.entries) {
        next = next.replaceAll(_pattern(entry.key), entry.value);
      }
      if (next == text) continue;
      await File(p.join(root, path)).writeAsString(next);
      changed.add(path);
    }
    return changed;
  }

  static RegExp _pattern(String symbol) =>
      RegExp('(?<![\\w\$])${RegExp.escape(symbol)}(?![\\w\$])');

  Stream<(String, String)> _sources() async* {
    final skip = p.normalize(output);
    for (final folder in folders) {
      final dir = Directory(p.join(root, folder));
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list(recursive: true)) {
        final path = p.normalize(p.relative(entity.path, from: root));
        if (entity is! File || !path.endsWith('.dart')) continue;
        if (path.endsWith('.g.dart') || p.isWithin(skip, path)) continue;
        yield (path, await entity.readAsString());
      }
    }
  }
}
