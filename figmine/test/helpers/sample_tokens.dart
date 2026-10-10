import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/icon_token.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_ref.dart';
import 'package:figmine/src/tokens/token_set.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

const _blue = ColorValue(r: 0, g: 0, b: 1);
const _white = ColorValue(r: 1, g: 1, b: 1);

/// Metadata of the sample file.
const FigmaFileMeta sampleMeta = FigmaFileMeta(
  name: 'DS',
  version: '1',
  lastModified: 'now',
);

/// A primitives collection and a light and dark semantic collection.
const TokenSet sampleTokens = TokenSet(
  meta: sampleMeta,
  collections: [
    TokenCollection(
      name: 'Primitives',
      modes: ['Value'],
      tokens: [
        DesignToken(
          path: ['palette', 'blue', '500'],
          type: TokenType.color,
          values: {'Value': TokenValue(_blue)},
          description: 'Brand blue.',
        ),
        DesignToken(
          path: ['radius', 'm'],
          type: TokenType.number,
          values: {'Value': TokenValue(12.0)},
        ),
      ],
    ),
    TokenCollection(
      name: 'Semantic',
      modes: ['Light', 'Dark'],
      tokens: [
        DesignToken(
          path: ['primary'],
          type: TokenType.color,
          values: {
            'Light': TokenValue(
              _blue,
              alias: TokenRef(
                collection: 'Primitives',
                path: ['palette', 'blue', '500'],
              ),
            ),
            'Dark': TokenValue(_white),
          },
        ),
        DesignToken(
          path: ['success'],
          type: TokenType.color,
          values: {'Light': TokenValue(_blue), 'Dark': TokenValue(_white)},
        ),
      ],
    ),
  ],
  textStyles: [
    TextStyleToken(
      path: ['Display', 'Large'],
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: 700,
      height: 1.25,
    ),
  ],
  icons: [
    IconToken(path: ['home'], svg: '<svg/>'),
  ],
);
