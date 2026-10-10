import 'dart:convert';
import 'dart:io';

import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:path/path.dart' as p;

/// A parsed design token file.
typedef DtcgFile = ({String name, Map<String, Object?> json});

/// Reads design token JSON files and folders.
abstract final class DtcgFiles {
  /// Loads every file in [paths], relative to [root]. Folders contribute
  /// their `.json` files in name order.
  static Future<List<DtcgFile>> load(String root, List<String> paths) async {
    final files = <File>[];
    for (final path in paths) {
      final target = p.join(root, path);
      if (FileSystemEntity.isDirectorySync(target)) {
        final children =
            Directory(target)
                .listSync()
                .whereType<File>()
                .where((f) => f.path.endsWith('.json'))
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        files.addAll(children);
        continue;
      }
      if (!File(target).existsSync()) {
        throw ConfigException('Token file $path does not exist.');
      }
      files.add(File(target));
    }
    return [
      for (final file in files)
        (
          name: p.basename(file.path),
          json: Json.map(jsonDecode(await file.readAsString())),
        ),
    ];
  }
}
