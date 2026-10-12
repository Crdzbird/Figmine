import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Builds text style tokens from Figma text styles.
abstract final class StyleTypography {
  /// Returns the text styles in [styles], sorted by name.
  static List<TextStyleToken> collect(
    List<StyleNode> styles,
    TypographyConfig config,
  ) {
    final tokens = <String, TextStyleToken>{};
    for (final style in styles) {
      if (style.type != 'TEXT') continue;
      final token = _read(style, config.pathOf(style.name));
      if (token != null) tokens.putIfAbsent(token.name, () => token);
    }
    final keys = tokens.keys.toList()..sort();
    return [for (final key in keys) tokens[key]!];
  }

  static TextStyleToken? _read(StyleNode style, List<String> path) {
    final type = Json.map(style.node['style']);
    final family = type['fontFamily'];
    final size = type['fontSize'];
    if (path.isEmpty || family is! String || size is! num) return null;
    final weight = type['fontWeight'];
    final lineHeight = type['lineHeightPx'];
    final spacing = type['letterSpacing'];
    final intrinsic = type['lineHeightUnit'] == 'INTRINSIC_%';
    return TextStyleToken(
      path: path,
      fontFamily: family,
      fontSize: size.toDouble(),
      fontWeight: weight is num
          ? (weight / 100).round().clamp(1, 9) * 100
          : 400,
      height: lineHeight is num && !intrinsic && size > 0
          ? lineHeight / size
          : null,
      letterSpacing: spacing is num && spacing != 0 ? spacing.toDouble() : null,
      italic: type['italic'] == true,
      decoration: switch (type['textDecoration']) {
        'UNDERLINE' => 'underline',
        'STRIKETHROUGH' => 'lineThrough',
        _ => null,
      },
      description: style.description.trim(),
    );
  }
}
