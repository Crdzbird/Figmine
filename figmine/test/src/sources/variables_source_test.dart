import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/variables_source.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';
import '../../helpers/variables_fixture.dart';

Future<List<TokenCollection>> _fetch(TokensConfig config) => VariablesSource(
  client: fakeFigma(json: {'/v1/files/KEY/variables/local': variablesJson}),
  config: config,
).fetch('KEY');

String _hex(Object value) => (value as ColorValue).hex;

void main() {
  group(VariablesSource, () {
    test('reads every collection with its modes, default first', () async {
      final collections = await _fetch(const TokensConfig());
      expect(collections.map((c) => c.name), ['Primitives', 'Semantic']);
      expect(collections.first.modes, ['Value']);
      expect(collections.last.modes, ['Light', 'Dark']);
    });

    test('reads colors, numbers and strings, skipping the rest', () async {
      final primitives = (await _fetch(const TokensConfig())).first;
      expect(primitives.tokens.map((t) => t.name), [
        'font/family',
        'palette/black',
        'palette/blue/500',
        'palette/white',
        'radius/16',
      ]);
      expect(primitives.find('radius/16')!.type, TokenType.number);
      expect(primitives.find('radius/16')!.values['Value']!.value, 16.0);
      expect(primitives.find('font/family')!.values['Value']!.value, 'Inter');
      expect(
        primitives.find('palette/blue/500')!.description,
        'Brand blue [500].',
      );
    });

    test('resolves aliases per mode and records the alias', () async {
      const config = TokensConfig(stripPrefix: 'color/');
      final semantic = (await _fetch(config)).last;
      expect(semantic.tokens.map((t) => t.name), [
        'on-primary',
        'primary',
        'success',
      ]);
      final primary = semantic.find('primary')!;
      expect(_hex(primary.values['Light']!.value), '0xFF0000FF');
      expect(_hex(primary.values['Dark']!.value), '0xFF8080FF');
      expect(
        primary.values['Light']!.alias!.label,
        'palette/blue/500 (Primitives)',
      );
      expect(primary.values['Light']!.alias!.mode, isNull);
      expect(primary.values['Dark']!.alias, isNull);
      final onPrimary = semantic.find('on-primary')!;
      expect(_hex(onPrimary.values['Dark']!.value), '0xFF000000');
    });

    test('filters collections by name', () async {
      final collections = await _fetch(
        const TokensConfig(collections: {'Semantic': ''}),
      );
      expect(collections.single.name, 'Semantic');
    });
  });
}
