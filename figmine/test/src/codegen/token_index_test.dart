import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/codegen/value_expressions.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';

TokenIndex _index([TokensConfig config = const TokensConfig()]) => TokenIndex(
  collections: sampleTokens.collections,
  prefix: 'App',
  config: config,
);

void main() {
  group(TokenIndex, () {
    test('names a class per group, and per mode for multi mode', () {
      final index = _index();
      expect(index.find('Primitives', 'palette/blue/500', null), (
        className: 'AppPrimitivesPaletteBlue',
        member: 'v500',
        file: 'color/primitives.g.dart',
      ));
      expect(
        index.find('Semantic', 'primary', 'Dark')!.className,
        'AppSemanticDark',
      );
      expect(
        index.find('Semantic', 'primary', 'Light')!.className,
        'AppSemanticLight',
      );
      expect(index.entries, hasLength(6));
    });

    test('uses configured collection segments', () {
      final index = _index(
        const TokensConfig(collections: {'Primitives': 'Core', 'Semantic': ''}),
      );
      expect(
        index.find('Primitives', 'radius/m', null)!.className,
        'AppCoreRadius',
      );
      expect(index.find('Semantic', 'success', 'Light')!.className, 'AppLight');
      expect(index.fileOf, {
        'Primitives': 'color/primitives.g.dart',
        'Semantic': 'color/semantic.g.dart',
      });
    });

    test('collections never take the names of fixed classes and files', () {
      final index = TokenIndex(
        collections: const [
          TokenCollection(
            name: 'Typography',
            modes: ['Value'],
            tokens: [
              DesignToken(
                path: ['base'],
                type: TokenType.number,
                values: {'Value': TokenValue(16.0)},
              ),
            ],
          ),
        ],
        prefix: 'App',
        config: const TokensConfig(),
        reservedClasses: {'AppTypography'},
      );
      expect(index.fileOf['Typography'], 'typography/typography.g.dart');
      expect(
        index.find('Typography', 'base', null)!.className,
        'AppTypographyTokens',
      );
    });

    test('references aliased constants and falls back to literals', () {
      final semantic = sampleTokens.collections.last;
      final primary = semantic.find('primary')!;
      final index = _index();
      expect(ValueExpressions.of(index, primary.values['Light']!), (
        code: 'AppPrimitivesPaletteBlue.v500',
        file: 'color/primitives.g.dart',
      ));
      expect(ValueExpressions.of(index, primary.values['Dark']!), (
        code: 'Color(0xFFFFFFFF)',
        file: null,
      ));
    });
  });
}
