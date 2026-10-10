import 'dart:io';

import 'package:path/path.dart' as p;

/// Removes generated files that the latest sync no longer produces.
abstract final class StaleFiles {
  /// Deletes every `.g.dart` file under [directory] of [root] that is not in
  /// [keep], paths relative to [root], then the folders left empty.
  /// Returns the deleted files.
  static Future<List<String>> prune(
    String root,
    String directory,
    Set<String> keep,
  ) async {
    final folder = Directory(p.join(root, directory));
    if (!folder.existsSync()) return const [];
    final deleted = <String>[];
    final entities = await folder.list(recursive: true).toList();
    for (final entity in entities.whereType<File>()) {
      final relative = p.normalize(p.relative(entity.path, from: root));
      if (!entity.path.endsWith('.g.dart') || keep.contains(relative)) continue;
      await entity.delete();
      deleted.add(relative);
    }
    final folders = entities.whereType<Directory>().toList()
      ..sort((a, b) => b.path.length.compareTo(a.path.length));
    for (final dir in folders) {
      if (dir.listSync().isEmpty) await dir.delete();
    }
    return deleted..sort();
  }
}
