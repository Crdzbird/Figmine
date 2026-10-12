import 'package:figmine/src/config/library_config.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/sources/styles/style_refs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_figma.dart';

Map<String, Object?> _style(String name, String node, [String? file]) => {
  'key': 'k-$name',
  'name': name,
  'style_type': 'FILL',
  'node_id': node,
  'file_key': ?file,
};

Map<String, Object?> _fills(List<String> ids) => {
  'nodes': {
    for (final id in ids)
      id: {
        'document': {
          'fills': [
            {
              'type': 'SOLID',
              'color': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
            },
          ],
        },
      },
  },
};

void main() {
  test('reads published, screen, remote, library and team styles', () async {
    final logs = <String>[];
    final client = fakeFigma(
      json: {
        '/v1/files/KEY/styles': {
          'meta': {
            'styles': [_style('brand', '1:1')],
          },
        },
        '/v1/styles/k-remote': {'meta': _style('remote', '5:5', 'LIB')},
        '/v1/files/LIB/styles': {
          'meta': {
            'styles': [_style('library', '6:6')],
          },
        },
        '/v1/teams/T/styles': {
          'meta': {
            'styles': [_style('team', '7:7', 'TEAMFILE')],
            'cursor': <String, Object?>{},
          },
        },
        '/v1/files/KEY/nodes': _fills(['1:1', '2:2']),
        '/v1/files/LIB/nodes': _fills(['5:5', '6:6']),
        '/v1/files/TEAMFILE/nodes': _fills(['7:7']),
      },
    );
    final styles =
        await StyleCatalog(
          client: client,
          refs: StyleRefs(
            client: client,
            library: const LibraryConfig(fileKeys: ['LIB'], teamId: 'T'),
            log: logs.add,
          ),
        ).fetch(
          'KEY',
          screens: const ScreenSet(
            frames: [],
            styles: {
              '2:2': {'name': 'used', 'styleType': 'FILL'},
              'S:9': {'key': 'k-remote', 'styleType': 'FILL', 'remote': true},
              'S:8': {'name': 'shadow', 'styleType': 'EFFECT'},
            },
          ),
        );
    expect(styles.map((s) => s.name), [
      'brand',
      'used',
      'remote',
      'library',
      'team',
    ]);
    expect(logs, isEmpty);
  });
}
