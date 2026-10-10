import 'package:figmine/src/codegen/role_ramps.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

DesignToken _token(String name, int argb) => DesignToken(
  path: name.split('/'),
  type: TokenType.color,
  values: {'Value': TokenValue(ColorValue.fromArgb(argb))},
);

final TonalPalette _sky = TonalPalette.of(230, 40);

final TokenCollection _palette = TokenCollection(
  name: 'palette',
  modes: const ['Value'],
  tokens: [
    _token('brand/primary', 0xFF3567F6),
    for (final (step, tone) in [
      (10, 95),
      (20, 90),
      (30, 80),
      (40, 70),
      (50, 60),
      (60, 50),
      (70, 40),
      (80, 30),
      (90, 20),
      (100, 10),
    ])
      _token('semantic/tertiary/$step', _sky.get(tone)),
  ],
);

void main() {
  final all = [
    for (final t in _palette.tokens) (collection: _palette, token: t),
  ];

  test('role scales are found and roles map onto their family', () {
    final ramps = RoleRamps.find(all);
    expect(ramps.keys, ['tertiary']);
    expect(ramps['tertiary']!.steps.first.token.name, 'semantic/tertiary/10');
    expect(RoleRamps.familyOf('onTertiaryContainer'), 'tertiary');
    expect(RoleRamps.familyOf('inversePrimary'), 'primary');
    expect(RoleRamps.familyOf('surfaceContainer'), 'neutral');
    expect(RoleRamps.familyOf('shadow'), isNull);
  });

  test('the key step is the most used among the most colorful', () {
    final ramp = RoleRamps.find(all)['tertiary']!;
    final vivid = ramp.key(const {});
    final used = ramp.key({_sky.get(70): 50});
    expect(used.token.name, 'semantic/tertiary/40');
    expect(vivid.token.name, isNot('semantic/tertiary/10'));
  });

  test('derived roles move onto the scale and surfaceTint follows primary', () {
    final fields = {
      for (final f in SchemeFields.resolve(
        matcher: SchemeMatcher(
          [_palette],
          const SchemeConfig(roles: {'primary': 'brand/primary'}),
          evidence: (
            roleVariables: const {},
            colorUses: {_sky.get(70): 50},
            componentColors: const {},
          ),
        ),
        index: TokenIndex(
          collections: [_palette],
          prefix: 'App',
          config: const TokensConfig(),
        ),
        tokens: const TokensConfig(),
      ))
        f.name: f,
    };
    expect(fields['tertiary']!.light.code, endsWith('.v40'));
    expect(fields['tertiaryContainer']!.light.code, contains('Tertiary'));
    expect(fields['tertiaryContainer']!.doc, contains('semantic/tertiary/'));
    expect(fields['onTertiaryContainer']!.dark.code, contains('Tertiary'));
    expect(fields['surfaceTint']!.light.code, fields['primary']!.light.code);
  });
}
