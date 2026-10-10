import 'dart:io';

import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_rate_limit.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;

void main() {
  test('long rate limits fail at once with the seat and the wait', () async {
    var calls = 0;
    final client = FigmaClient(
      httpClient: MockClient((_) async {
        calls++;
        return http.Response(
          '{"status":429}',
          429,
          headers: {
            'retry-after': '399731',
            'x-figma-rate-limit-type': 'low',
            'x-figma-plan-tier': 'org',
          },
        );
      }),
      token: 't',
    );
    await expectLater(
      client.getJson('/v1/files/K/nodes'),
      throwsA(
        isA<FigmaRateLimit>()
            .having((e) => e.wait, 'wait', '4d 15h 2m')
            .having((e) => e.toString(), 'message', contains('View or Collab')),
      ),
    );
    expect(calls, 1);
  });

  test('heavy reads are cached per file version', () async {
    final temp = await Directory.systemTemp.createTemp('figmine_cache');
    addTearDown(() => temp.delete(recursive: true));
    var calls = 0;
    FigmaClient client(ReadCache cache) => FigmaClient(
      httpClient: MockClient((_) async {
        calls++;
        return http.Response('{"n": $calls}', 200);
      }),
      token: 't',
      cache: cache,
    );
    final first = ReadCache(temp.path);
    await first.pin('K', 'v1');
    expect(await client(first).getJson('/v1/files/K/nodes'), {'n': 1});
    await client(first).getJson('/v1/files/K/meta');
    expect((first.fetched, first.reused), (1, 0));

    final again = ReadCache(temp.path);
    await again.pin('K', 'v1');
    expect(await client(again).getJson('/v1/files/K/nodes'), {'n': 1});
    expect((again.fetched, again.reused), (0, 1));

    final next = ReadCache(temp.path);
    await next.pin('K', 'v2');
    expect(await client(next).getJson('/v1/files/K/nodes'), {'n': 3});
    expect(Directory(p.join(temp.path, 'K', 'v1')).existsSync(), isFalse);
  });
}
