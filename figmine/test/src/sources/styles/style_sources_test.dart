import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/sources/styles/style_colors.dart';
import 'package:figmine/src/sources/styles/style_typography.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_figma.dart';
import '../../../helpers/style_catalog_helper.dart';
import '../../../helpers/styles_fixture.dart';

Future<List<StyleNode>> _catalog() => styleCatalog(
  fakeFigma(
    json: {'/v1/files/KEY': fileJson, '/v1/files/KEY/nodes': styleNodesJson},
  ),
).fetch('KEY');

void main() {
  test('the catalog loads fill and text styles only', () async {
    final styles = await _catalog();
    expect(styles.map((s) => s.type).toSet(), {'FILL', 'TEXT'});
    expect(styles, hasLength(5));
  });

  group(StyleColors, () {
    test('pairs light and dark styles into a two mode collection', () async {
      final collection = StyleColors.collect(
        await _catalog(),
        const TokensConfig(),
      )!;
      expect(collection.name, 'Styles');
      expect(collection.modes, ['light', 'dark']);
      expect(collection.tokens.map((t) => t.name), ['brand/accent', 'primary']);
      final primary = collection.find('primary')!;
      expect((primary.values['light']!.value as ColorValue).hex, '0xFFFF0000');
      expect((primary.values['dark']!.value as ColorValue).hex, '0x80800000');
      final accent = collection.find('brand/accent')!;
      expect((accent.values['dark']!.value as ColorValue).hex, '0xFF00FF00');
    });

    test('returns null without fill styles', () {
      expect(StyleColors.collect(const [], const TokensConfig()), isNull);
    });
  });

  group(StyleTypography, () {
    test('reads text styles', () async {
      final styles = StyleTypography.collect(
        await _catalog(),
        const TypographyConfig(),
      );
      expect(styles.map((s) => s.name), ['Display/Large', 'body']);
      final display = styles.first;
      expect(display.fontWeight, 700);
      expect(display.height, 1.25);
      expect(display.letterSpacing, -0.25);
      final body = styles.last;
      expect(body.fontWeight, 500);
      expect(body.height, isNull);
      expect(body.italic, isTrue);
      expect(body.decoration, 'underline');
    });
  });
}
