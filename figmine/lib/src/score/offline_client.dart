import 'dart:convert';

import 'package:http/http.dart' as http;

/// An HTTP client that answers every request with 404, so reads come only
/// from the cache and a missing entry behaves like a missing resource.
final class OfflineClient extends http.BaseClient {
  /// Creates the client.
  factory() = OfflineClient._;

  new _();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = jsonEncode({
      'status': 404,
      'err': '${request.url.path} is not in the figmine cache',
    });
    return http.StreamedResponse(Stream.value(utf8.encode(body)), 404);
  }
}
