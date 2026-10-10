import 'dart:io';

import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/read_cache.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/lock_json.dart';
import 'package:figmine/src/pipeline/canvas_fetcher.dart';
import 'package:figmine/src/pipeline/offline_source.dart';
import 'package:figmine/src/score/offline_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('every read of a version is cacheable except meta and images', () {
    expect(ReadCache.cacheable('/v1/files/K'), isTrue);
    expect(ReadCache.cacheable('/v1/files/K/styles'), isTrue);
    expect(ReadCache.cacheable('/v1/styles/abc'), isTrue);
    expect(ReadCache.cacheable('/v1/files/K/meta'), isFalse);
    expect(ReadCache.cacheable('/v1/images/K'), isFalse);
  });

  test('offline reads miss as 404, so fallbacks behave as online', () async {
    final client = FigmaClient(httpClient: OfflineClient(), token: 'offline');
    await expectLater(
      client.getJson('/v1/files/K/variables/local'),
      throwsA(isA<FigmaException>().having((e) => e.statusCode, 'code', 404)),
    );
  });

  test('offline meta comes from the lock file, with the file name', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_offline');
    addTearDown(() => dir.delete(recursive: true));
    const lock = LockFile(
      fileKey: 'AbC123xyzAbC',
      version: '42',
      lastModified: '2026-10-10',
      fileName: 'Design System',
    );
    await File(p.join(dir.path, 'figmine.lock.json'))
        .writeAsString(LockJson.encode(lock));
    final config = FigmineConfig.fromYaml(const {
      'figma': {'file_key': 'AbC123xyzAbC'},
    });
    final meta = await OfflineSource.meta(dir.path, config);
    expect((meta.name, meta.version), ('Design System', '42'));
  });

  test('without a lock file, offline meta comes from the export', () async {
    final dir = await Directory.systemTemp.createTemp('figmine_export');
    addTearDown(() => dir.delete(recursive: true));
    await File(p.join(dir.path, 'design-tokens.json')).writeAsString(
      r'{"$extensions": {"figmine": {"file": "Brand", "exportedAt": "T"}}}',
    );
    final config = FigmineConfig.fromYaml(const {
      'figma': {'file_key': 'AbC123xyzAbC'},
      'tokens': {
        'files': ['design-tokens.json'],
      },
    });
    final meta = await OfflineSource.meta(dir.path, config);
    expect((meta.name, meta.version, meta.lastModified), ('Brand', '', 'T'));
  });

  test('offline, screens never cached are skipped, not an error', () async {
    final logs = <String>[];
    final screens = await CanvasFetcher(
      client: FigmaClient(httpClient: OfflineClient(), token: 'offline'),
      config: FigmineConfig.fromYaml(const {
        'figma': {'file_key': 'AbC123xyzAbC'},
      }),
      log: logs.add,
    ).screens(offline: true);
    expect(screens, isNull);
    expect(logs.single, startsWith('No screens cached'));
  });
}
