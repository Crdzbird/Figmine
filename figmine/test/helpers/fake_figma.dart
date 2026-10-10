import 'dart:convert';

import 'package:figmine/src/figma/figma_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// SVG bodies served from the fake asset host, keyed by path.
const Map<String, String> fakeSvgs = {
  '/home.svg':
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
      'viewBox="0 0 24 24"><path d="M3 10.5 12 3l9 7.5V21h-6v-6H9v6H3z" '
      'fill="#000"/></svg>',
  '/arrow.svg':
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" '
      'viewBox="0 0 24 24"><path d="M20 11H7.8l5.6-5.6L12 4l-8 8 8 8 '
      '1.4-1.4L7.8 13H20z" fill="#000"/></svg>',
};

/// Builds a client that serves [json] by API path and fails [errors].
///
/// A key such as `/path?ids=1:2` matches only requests for those ids.
MockClient fakeFigmaHttp({
  Map<String, Object?> json = const {},
  Map<String, int> errors = const {},
  List<http.BaseRequest>? requests,
}) => MockClient((request) async {
  requests?.add(request);
  final path = request.url.path;
  if (request.url.host != 'api.figma.com') {
    final svg = fakeSvgs[path];
    return http.Response(svg ?? 'missing', svg == null ? 404 : 200);
  }
  final status = errors[path];
  if (status != null) return http.Response('{"status":$status}', status);
  final ids = request.url.queryParameters['ids'];
  final body = json['$path?ids=$ids'] ?? json[path];
  if (body == null) return http.Response('{"err":"Not found"}', 404);
  return http.Response(jsonEncode(body), 200);
});

/// Builds a [FigmaClient] over [fakeFigmaHttp].
FigmaClient fakeFigma({
  Map<String, Object?> json = const {},
  Map<String, int> errors = const {},
  List<http.BaseRequest>? requests,
}) => FigmaClient(
  httpClient: fakeFigmaHttp(json: json, errors: errors, requests: requests),
  token: 'test-token',
  retryDelay: Duration.zero,
);

/// The `/meta` response for [version].
Map<String, Object?> metaJson(String version) => {
  'file': {
    'name': 'Design System',
    'version': version,
    'last_touched_at': '2026-10-01T00:00:00Z',
  },
};
