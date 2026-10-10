import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/style_catalog_helper.dart';

Map<String, Object?> _fills(String id) => {
  'nodes': {
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
  test('works with only file_content:read', () async {
    final client = fakeFigma(
      json: {
        '/v1/files/KEY': {
          'styles': {
            '2:2': {'name': 'local', 'styleType': 'FILL'},
          },
        },
        '/v1/files/KEY/nodes': _fills('2:2'),
      },
      errors: {'/v1/files/KEY/styles': 403},
    );
    final styles = await styleCatalog(client).fetch('KEY');
    expect(styles.single.name, 'local');
  });
}
