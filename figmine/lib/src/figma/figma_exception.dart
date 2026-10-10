/// Thrown when the Figma REST API answers with an error.
final class FigmaException implements Exception {
  /// Creates an exception for a failed request.
  const factory({
    required int statusCode,
    required String path,
    required String body,
  }) = FigmaException._;

  const new _({
    required this.statusCode,
    required this.path,
    required this.body,
  });

  /// Creates an exception from a failed response.
  factory from(int statusCode, String path, String body) =>
      FigmaException(statusCode: statusCode, path: path, body: body);

  /// HTTP status code returned by Figma.
  final int statusCode;

  /// Request path.
  final String path;

  /// Raw response body.
  final String body;

  @override
  String toString() => 'Figma request $path failed ($statusCode): $body';
}
