import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

DesignToken _token(String name, int light, int dark, String id) => DesignToken(
  path: name.split('/'),
  type: TokenType.color,
  values: {
    'Light': TokenValue(ColorValue.fromArgb(light)),
    'Dark': TokenValue(ColorValue.fromArgb(dark)),
  },
  variableId: id,
);

void main() {
  final collection = TokenCollection(
    name: 'Color',
    modes: const ['Light', 'Dark'],
    tokens: [
      _token('Brand/Default', 0xFF2C2C2C, 0xFFF5F5F5, 'V:brand'),
      _token('Brand/Hover', 0xFF1E1E1E, 0xFFD9D9D9, 'V:hover'),
    ],
  );
  final fields = {
    for (final f in SchemeFields.resolve(
      matcher: SchemeMatcher(
        [collection],
        const SchemeConfig(roles: {'primary': 'Brand/Default'}),
        evidence: (
          roleVariables: const {},
          colorUses: const {},
          componentColors: const {
            'button.enabled.fill': (argb: 0xFF2C2C2C, variable: 'V:brand'),
            'button.hovered.fill': (argb: 0xFF1E1E1E, variable: 'V:hover'),
          },
        ),
      ),
      index: TokenIndex(
        collections: [collection],
        prefix: 'App',
        config: const TokensConfig(),
      ),
      tokens: const TokensConfig(),
    ))
      f.name: f,
  };

  test('a state bound to a variable references its token in both modes', () {
    expect(fields['buttonHovered']!.light.code, 'AppColorBrandLight.hover');
    expect(fields['buttonHovered']!.darkArgb, 0xFFD9D9D9);
  });

  test('pressed follows the hover direction in each mode', () {
    final pressed = fields['buttonPressed']!;
    expect(pressed.doc, contains('Follows the hovered variant'));
    expect(
      ColorMath.luminance(pressed.lightArgb),
      lessThan(ColorMath.luminance(0xFF1E1E1E)),
    );
    expect(
      ColorMath.luminance(pressed.darkArgb),
      lessThan(ColorMath.luminance(0xFFD9D9D9)),
    );
  });

  test('states missing from Figma use the Material defaults', () {
    expect(fields['buttonDisabled']!.doc, contains('Material default'));
    expect(fields['inputFocusedOutline']!.lightArgb, 0xFF2C2C2C);
    expect(fields.keys, containsAll(['chipSelected', 'onChipSelected']));
  });
}
