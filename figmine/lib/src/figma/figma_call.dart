import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_rate_limit.dart';
import 'package:http/http.dart' as http;

/// Sends one authenticated request, waiting out short rate limits.
final class FigmaCall {
  /// Creates a sender for [token].
  const factory({
    required http.Client httpClient,
    required String token,
    required Duration retryDelay,
    required Duration maxWait,
  }) = FigmaCall._;

  const new _({
    required this.httpClient,
    required this.token,
    required this.retryDelay,
    required this.maxWait,
  });

  /// The HTTP client.
  final http.Client httpClient;

  /// The Figma personal access token.
  final String token;

  /// Wait between retries when Figma does not say how long.
  final Duration retryDelay;

  /// Longest wait accepted before failing with [FigmaRateLimit].
  final Duration maxWait;

  static const int _maxAttempts = 4;

  /// Sends [method] to [uri] with an optional JSON [body]. [path] names the
  /// request in errors.
  Future<http.Response> send(
    String method,
    Uri uri,
    String path,
    String? body, [
    int attempt = 1,
  ]) async {
    final request = http.Request(method, uri)..headers['X-Figma-Token'] = token;
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = body;
    }
    final response = await http.Response.fromStream(
      await httpClient.send(request),
    );
    final code = response.statusCode;
    if (code >= 200 && code < 300) return response;
    if (code != 429) throw FigmaException.from(code, path, response.body);
    final limit = FigmaRateLimit.from(path, response.headers);
    if (attempt >= _maxAttempts || limit.retryAfter > maxWait.inSeconds) {
      throw limit;
    }
    await Future<void>.delayed(
      limit.retryAfter == 0 ? retryDelay : Duration(seconds: limit.retryAfter),
    );
    return await send(method, uri, path, body, attempt + 1);
  }
}
