import 'package:figmine/src/figma/json.dart';

/// One saved version of a Figma file.
final class FigmaVersion {
  /// Creates a version.
  const factory({
    required String id,
    required String createdAt,
    String label,
    String description,
    String author,
  }) = FigmaVersion._;

  const new _({
    required this.id,
    required this.createdAt,
    this.label = '',
    this.description = '',
    this.author = '',
  });

  /// Reads one entry of `GET /v1/files/:key/versions`.
  factory fromJson(Map<String, Object?> json) => FigmaVersion(
    id: '${json['id'] ?? ''}',
    createdAt: '${json['created_at'] ?? ''}',
    label: '${json['label'] ?? ''}',
    description: '${json['description'] ?? ''}',
    author: '${Json.map(json['user'])['handle'] ?? ''}',
  );

  /// Version id, the same value the lock file stores.
  final String id;

  /// ISO 8601 creation time.
  final String createdAt;

  /// Named version label, empty for autosaves.
  final String label;

  /// Named version description.
  final String description;

  /// Handle of the person who saved the version.
  final String author;
}
