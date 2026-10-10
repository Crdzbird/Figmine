import 'dart:convert';

import 'package:figmine/src/figma/figma_call.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:http/http.dart' as http;

/// Minimal client for the Figma REST API.
final class FigmaClient {
  /// Creates a client that authenticates with a personal access [token].
  const factory({
    required http.Client httpClient,
    required String token,
    String baseUrl,
    Duration retryDelay,
    Duration maxWait,
    ReadCache? cache,
  }) = FigmaClient._;

  const new _({
    required this.httpClient,
    required this.token,
    this.baseUrl = 'https://api.figma.com',
    this.retryDelay = const Duration(seconds: 5),
    this.maxWait = const Duration(minutes: 2),
    this.cache,
  });

  /// The HTTP client used for every request.
  final http.Client httpClient;

  /// The Figma personal access token.
  final String token;

  /// The API origin.
  final String baseUrl;

  /// Fallback wait between retries of rate limited requests.
  final Duration retryDelay;

  /// Longest wait figmine accepts before failing a rate limited request.
  final Duration maxWait;

  /// Keeps heavy reads by file version and counts them, when set.
  final ReadCache? cache;

  /// Sends `GET` to [path] and decodes the JSON object response.
  Future<Map<String, Object?>> getJson(
    String path, [
    Map<String, String> query = const {},
  ]) => send('GET', path, query: query);

  /// Sends [method] to [path] with an optional JSON [body], returning the
  /// decoded object, or an empty map for an empty response.
  Future<Map<String, Object?>> send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, Object?>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path')
        .replace(queryParameters: query.isEmpty ? null : query);
    final cached = method == 'GET' ? await cache?.read(uri) : null;
    final text =
        cached ??
        (await FigmaCall(
          httpClient: httpClient,
          token: token,
          retryDelay: retryDelay,
          maxWait: maxWait,
        ).send(method, uri, path, body == null ? null : jsonEncode(body))).body;
    if (cached == null && method == 'GET' && cache != null) {
      if (cache!.isHeavy(path)) cache!.fetched++;
      await cache!.write(uri, text);
    }
    if (text.trim().isEmpty) return const {};
    final decoded = jsonDecode(text);
    if (decoded is Map<String, Object?>) return decoded;
    throw FigmaException.from(200, path, text);
  }

  /// Downloads a rendered asset, such as an exported SVG, as text.
  ///
  /// Asset URLs are pre-signed, so the token is not sent.
  Future<String> download(Uri uri) async {
    final response = await httpClient.get(uri);
    if (response.statusCode == 200) return response.body;
    throw FigmaException.from(response.statusCode, uri.path, response.body);
  }
}
