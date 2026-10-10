import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/sources/icons_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../helpers/fake_figma.dart';
import '../../helpers/icons_fixture.dart';

void main() {
  group(IconsSource, () {
    test('exports prefixed components and variants as SVG', () async {
      final requests = <http.BaseRequest>[];
      final source = IconsSource(
        client: fakeFigma(
          json: {
            '/v1/files/KEY/nodes': iconNodesJson,
            '/v1/images/KEY': imagesJson,
          },
          requests: requests,
        ),
        config: const IconsConfig(nodeIds: ['1:2'], namePrefix: 'icon/'),
      );
      final icons = await source.fetch('KEY');
      expect(icons.map((i) => i.name), ['arrow/Direction=Left', 'home']);
      expect(icons.last.svg, fakeSvgs['/home.svg']);
      final render = requests.firstWhere((r) => r.url.path.contains('images'));
      expect(render.url.queryParameters['format'], 'svg');
      expect(render.url.queryParameters['ids']!.split(','), ['1:3', '1:5']);
      final downloads = requests.where((r) => r.url.host != 'api.figma.com');
      expect(downloads, hasLength(2));
      for (final download in downloads) {
        expect(download.headers.containsKey('X-Figma-Token'), isFalse);
      }
    });
  });
}
