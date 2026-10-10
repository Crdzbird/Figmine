import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group(FigmaClient, () {
    test('sends the token and query, and decodes JSON', () async {
      late http.Request seen;
      final client = FigmaClient(
        httpClient: MockClient((request) async {
          seen = request;
          return http.Response('{"ok": true}', 200);
        }),
        token: 'secret',
      );
      final json = await client.getJson('/v1/files/K', {'depth': '1'});
      expect(json, {'ok': true});
      expect(seen.headers['X-Figma-Token'], 'secret');
      expect(seen.url.toString(), 'https://api.figma.com/v1/files/K?depth=1');
    });

    test('sends JSON bodies and accepts empty responses', () async {
      late http.Request seen;
      final client = FigmaClient(
        httpClient: MockClient((request) async {
          seen = request;
          return http.Response('', 200);
        }),
        token: 't',
      );
      final json = await client.send('POST', '/v1/x', body: {'a': 1});
      expect(json, isEmpty);
      expect(seen.method, 'POST');
      expect(seen.body, '{"a":1}');
      expect(seen.headers['Content-Type'], startsWith('application/json'));
    });

    test('retries rate limited requests', () async {
      var calls = 0;
      final client = FigmaClient(
        httpClient: MockClient((request) async {
          calls++;
          if (calls < 3) return http.Response('slow down', 429);
          return http.Response('{}', 200);
        }),
        token: 't',
        retryDelay: Duration.zero,
      );
      await client.getJson('/v1/x');
      expect(calls, 3);
    });

    test('throws FigmaException with the status code', () async {
      final client = FigmaClient(
        httpClient: MockClient((_) async => http.Response('nope', 403)),
        token: 't',
      );
      await expectLater(
        client.getJson('/v1/x'),
        throwsA(
          isA<FigmaException>()
              .having((e) => e.statusCode, 'statusCode', 403)
              .having((e) => e.toString(), 'message', contains('nope')),
        ),
      );
    });
  });

  group(FigmaFileMeta, () {
    test('reads the meta endpoint shape', () {
      final meta = FigmaFileMeta.fromJson({
        'file': {'name': 'DS', 'version': '7', 'last_touched_at': 'now'},
      });
      expect([meta.name, meta.version, meta.lastModified], ['DS', '7', 'now']);
    });
  });
}
