import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

DesignToken _token(String name, int light, int dark, [String? id]) =>
    DesignToken(
      path: [name],
      type: TokenType.color,
      variableId: id,
      values: {
        'Light': TokenValue(ColorValue.fromArgb(light)),
        'Dark': TokenValue(ColorValue.fromArgb(dark)),
      },
    );

void main() {
  test('a white fill copies a white fill, not white text', () {
    final collection = TokenCollection(
      name: 'Color',
      modes: const ['Light', 'Dark'],
      tokens: [
        _token('brand', 0xFF2C2C2C, 0xFFF5F5F5),
        _token('on brand', 0xFFFFFFFF, 0xFF000000),
        _token('page', 0xFFFFFFFF, 0xFF1E1E1E),
        _token('ink', 0xFF1D1B20, 0xFFE6E0E9, 'V:ink'),
      ],
    );
    final fields = SchemeFields.resolve(
      matcher: SchemeMatcher(
        [collection],
        const SchemeConfig(
          roles: {
            'primary': 'brand',
            'onPrimary': 'on brand',
            'surface': 'page',
          },
        ),
        evidence: (
          roleVariables: const {},
          colorUses: const {},
          componentColors: const {
            'input.enabled.fill': (argb: 0xFFFFFFFF, variable: null),
            'input.disabled.label': (argb: 0x611D1B20, variable: 'V:ink'),
          },
        ),
      ),
      index: TokenIndex(
        collections: [collection],
        prefix: 'App',
        config: const TokensConfig(),
      ),
      tokens: const TokensConfig(),
    );
    final input = fields.firstWhere((f) => f.name == 'input');
    expect(input.darkArgb, 0xFF1E1E1E);
    final faded = fields.firstWhere((f) => f.name == 'onInputDisabled');
    expect((faded.lightArgb, faded.darkArgb), (0x611D1B20, 0x61E6E0E9));
  });

  test('only switch names the switch kind outright', () {
    expect(ComponentKind.match('tag toggle state=off'), ComponentKind.toggle);
    expect(RegExp(ComponentKind.toggle.strong).hasMatch('tag toggle'), isFalse);
    expect(
      RegExp(ComponentKind.toggle.strong).hasMatch('switch field'),
      isTrue,
    );
  });
}
