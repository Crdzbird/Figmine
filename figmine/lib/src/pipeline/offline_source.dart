import 'dart:io';

import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/pipeline/project_files.dart';
import 'package:figmine/src/sources/dtcg/dtcg_files.dart';
import 'package:figmine/src/tokens/icon_token.dart';
import 'package:path/path.dart' as p;

/// What an offline sync takes from the project instead of Figma.
abstract final class OfflineSource {
  /// The file name and version recorded in the lock file of [root]. The
  /// first offline sync of exported token files, before any lock file,
  /// takes the file name and export time the exporter plugin wrote.
  static Future<FigmaFileMeta> meta(String root, FigmineConfig config) async {
    final lock = await ProjectFiles(root).readLock(config.lockFile);
    if (lock == null) return await _exported(root, config);
    return FigmaFileMeta(
      name: lock.fileName.isEmpty ? config.fileKey : lock.fileName,
      version: lock.version,
      lastModified: lock.lastModified,
    );
  }

  static Future<FigmaFileMeta> _exported(
    String root,
    FigmineConfig config,
  ) async {
    final files = config.tokens.files;
    if (files.isEmpty) {
      throw ConfigException(
        'Offline syncs need ${config.lockFile} or tokens.files. Run figmine '
        'generate online once, or export design-tokens.json with the plugin.',
      );
    }
    final json = (await DtcgFiles.load(root, files)).first.json;
    final figmine = Json.map(Json.map(json[r'$extensions'])['figmine']);
    final name = '${figmine['file'] ?? ''}';
    return FigmaFileMeta(
      name: name.isEmpty ? config.fileKey : name,
      version: '',
      lastModified: '${figmine['exportedAt'] ?? ''}',
    );
  }

  /// The icons exported before, read back from their SVG files.
  static Future<List<IconToken>> icons(
    String root,
    FigmineConfig config,
  ) async {
    final icons = config.icons;
    final dir = Directory(p.join(root, icons?.output ?? ''));
    if (icons == null || !dir.existsSync()) return const [];
    final files = dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.svg'),
    );
    return [
      for (final file
          in files.toList()..sort((a, b) => a.path.compareTo(b.path)))
        IconToken(
          path: [p.basenameWithoutExtension(file.path)],
          svg: await file.readAsString(),
        ),
    ];
  }
}
