import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/scheme/role_pairs.dart';
import 'package:figmine/src/codegen/scheme/scheme_fields.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/codegen/typography/typography_roles.dart';
import 'package:figmine/src/config/scheme_config.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_tokens.dart';

void main() {
  test('foregrounds only come from Figma with their backgrounds', () {
    final semantic = sampleTokens.collections.last;
    final token = semantic.find('primary')!;
    final roles = {'onSecondary': (collection: semantic, token: token)};
    expect(RolePairs.consistent(roles), isEmpty);
    expect(
      RolePairs.readable({'surface': (collection: semantic, token: token)}),
      {'onSurface'},
    );
    expect(RolePairs.readable(const {}, {'secondary'}), {'onSecondary'});
    final figmaText = {
      'secondary': (collection: semantic, token: token),
      'onSecondary': (collection: semantic, token: token),
    };
    expect(RolePairs.consistent(figmaText, {'secondary'}).keys, ['secondary']);
    expect(RolePairs.readable(const {}, {'secondary', 'onSecondary'}), isEmpty);
  });

  test('single mode collections get a derived dark value', () {
    final primitives = sampleTokens.collections.first;
    final fields = SchemeFields.resolve(
      matcher: SchemeMatcher(
        sampleTokens.collections,
        const SchemeConfig(roles: {'primary': 'palette/blue/500'}),
      ),
      index: TokenIndex(
        collections: sampleTokens.collections,
        prefix: 'App',
        config: const TokensConfig(),
      ),
      tokens: const TokensConfig(),
    );
    final primary = fields.firstWhere((f) => f.name == 'primary');
    expect(primitives.multiMode, isFalse);
    expect(primary.light.code, 'AppPrimitivesPaletteBlue.v500');
    expect(primary.dark.code, startsWith('Color(0x'));
    expect(primary.doc, contains('The dark value is derived.'));
    final onPrimary = fields.firstWhere((f) => f.name == 'onPrimary');
    expect(onPrimary.doc, 'Readable text on `primary`.');
  });

  test('unnamed roles take the closest style, preferring role names', () {
    TextStyleToken style(String name, double size, [int weight = 400]) =>
        TextStyleToken(
          path: name.split('/'),
          fontFamily: 'Ambit',
          fontSize: size,
          fontWeight: weight,
        );
    final roles = TypographyRoles.match([
      style('Heading/H2', 32, 700),
      style('Forms/Input', 14),
      style('Body/B3', 14),
    ], const TypographyConfig());
    expect(roles['headlineLarge']!.name, 'Heading/H2');
    expect(roles['bodyMedium']!.name, 'Body/B3');
  });
}
