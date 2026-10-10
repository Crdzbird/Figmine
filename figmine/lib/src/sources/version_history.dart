import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_version.dart';
import 'package:figmine/src/figma/json.dart';

/// Reads the versions saved since the last sync. Needs `file_versions:read`.
final class VersionHistory {
  /// Creates a reader for [fileKey].
  const factory({required FigmaClient client, required String fileKey}) =
      VersionHistory._;

  const new _({required this.client, required this.fileKey});

  /// The Figma client.
  final FigmaClient client;

  /// The file to read.
  final String fileKey;

  static const int _maxPages = 3;

  /// Versions newer than [since], newest first.
  ///
  /// Reads at most a few pages. Returns an empty list without the scope.
  Future<List<FigmaVersion>> since(String? since) async {
    final versions = <FigmaVersion>[];
    var query = <String, String>{'page_size': '50'};
    for (var page = 0; page < _maxPages; page++) {
      final Map<String, Object?> json;
      try {
        json = await client.getJson('/v1/files/$fileKey/versions', query);
      } on FigmaException catch (error) {
        if (error.statusCode == 403 || error.statusCode == 404) return versions;
        rethrow;
      }
      for (final raw in Json.list(json['versions'])) {
        final version = FigmaVersion.fromJson(Json.map(raw));
        if (version.id == since) return versions;
        versions.add(version);
      }
      final next = Uri.tryParse(
        '${Json.map(json['pagination'])['next_page'] ?? ''}',
      );
      final before = next?.queryParameters['before'];
      if (before == null || since == null) return versions;
      query = {'page_size': '50', 'before': before};
    }
    return versions;
  }
}
