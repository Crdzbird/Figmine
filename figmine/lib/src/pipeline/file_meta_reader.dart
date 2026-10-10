import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/figma/figma_version.dart';
import 'package:figmine/src/pipeline/offline_source.dart';
import 'package:figmine/src/sources/version_history.dart';

/// Reads the name, version and history of the Figma file.
final class FileMetaReader {
  /// Creates a reader for the file in [config].
  const factory({
    required FigmaClient client,
    required FigmineConfig config,
    required String root,
    required bool offline,
  }) = FileMetaReader._;

  const new _({
    required this.client,
    required this.config,
    required this.root,
    required this.offline,
  });

  /// The Figma client.
  final FigmaClient client;

  /// The project configuration.
  final FigmineConfig config;

  /// The project folder.
  final String root;

  /// Whether to read the lock file instead of Figma.
  final bool offline;

  /// The file name and current version, from the lock file offline, else
  /// from `file_metadata:read`, falling back to a shallow file read.
  Future<FigmaFileMeta> read() async {
    if (offline) return await OfflineSource.meta(root, config);
    final file = '/v1/files/${config.fileKey}';
    try {
      return FigmaFileMeta.fromJson(await client.getJson('$file/meta'));
    } on FigmaException catch (error) {
      if (error.statusCode != 403) rethrow;
      return FigmaFileMeta.fromJson(await client.getJson(file, {'depth': '1'}));
    }
  }

  /// Versions saved after [since], when `file_versions:read` is granted;
  /// none offline.
  Future<List<FigmaVersion>> versions(String? since) async {
    if (offline) return const [];
    final history = VersionHistory(client: client, fileKey: config.fileKey);
    return await history.since(since);
  }
}
