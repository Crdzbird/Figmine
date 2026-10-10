import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/screens/screen_loader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../helpers/fake_figma.dart';
import '../../helpers/screens_fixture.dart';
import '../../helpers/screens_tree.dart';

void main() {
  group(ScreenLoader, () {
    test(
      'lists frames shallowly, skips cover pages, loads in batches',
      () async {
        final requests = <http.BaseRequest>[];
        final screens = await ScreenLoader(
          client: fakeFigma(
            json: {
              '/v1/files/KEY': screensTree,
              '/v1/files/KEY/nodes': screenNodesJson,
            },
            requests: requests,
          ),
          config: const InferenceConfig(),
        ).load('KEY');
        expect(screens.frames.map((f) => f.page), ['App', 'App']);
        expect(screens.components.keys, contains('C:btn'));
        expect(screens.componentSets['S:btn']!['name'], 'Button');
        expect(requests.first.url.queryParameters['depth'], '2');
        expect(requests.last.url.queryParameters['ids'], '1:1,1:2');
      },
    );

    test('configured node ids skip the page listing', () async {
      final requests = <http.BaseRequest>[];
      final screens = await ScreenLoader(
        client: fakeFigma(
          json: {'/v1/files/KEY/nodes': screenNodesJson},
          requests: requests,
        ),
        config: const InferenceConfig(nodeIds: ['1:1']),
      ).load('KEY');
      expect(screens.frames, hasLength(1));
      expect(requests, hasLength(1));
    });

    test('pages and excludes are matched case insensitively', () {
      const config = InferenceConfig();
      expect(config.includesPage('Cover'), isFalse);
      expect(config.includesPage('Old flows'), isFalse);
      expect(config.includesPage('Checkout'), isTrue);
      expect(
        const InferenceConfig(pages: ['checkout']).includesPage('Home'),
        isFalse,
      );
    });
  });
}
