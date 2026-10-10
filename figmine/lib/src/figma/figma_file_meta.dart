/// Name and version of a Figma file.
final class FigmaFileMeta {
  /// Creates file metadata.
  const factory({
    required String name,
    required String version,
    required String lastModified,
  }) = FigmaFileMeta._;

  const new _({
    required this.name,
    required this.version,
    required this.lastModified,
  });

  /// Reads the response of `GET /v1/files/:key/meta`.
  factory fromJson(Map<String, Object?> json) {
    final file = json['file'];
    final data = file is Map ? file : json;
    return FigmaFileMeta(
      name: '${data['name'] ?? ''}',
      version: '${data['version'] ?? ''}',
      lastModified: '${data['last_touched_at'] ?? data['lastModified'] ?? ''}',
    );
  }

  /// The file name.
  final String name;

  /// The Figma version id, which changes on every saved edit.
  final String version;

  /// ISO 8601 timestamp of the last edit.
  final String lastModified;

  /// The quoted name, with the version when there is one.
  String get label =>
      version.isEmpty ? '"$name"' : '"$name" at version $version';
}
