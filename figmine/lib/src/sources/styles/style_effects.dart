import 'package:figmine/src/sources/styles/style_catalog.dart';
import 'package:figmine/src/sources/styles/style_effect_values.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Builds a collection of shadows and gradients from effect and fill
/// styles.
abstract final class StyleEffects {
  /// Name of the collection.
  static const String collectionName = 'Effects';

  static const String _mode = 'Value';

  /// [collections] with the effects of [styles] added, unless they hold
  /// shadows or gradients already, such as from the exporter plugin.
  static List<TokenCollection> addTo(
    List<TokenCollection> collections,
    List<StyleNode> styles,
  ) {
    final has = collections.any(
      (c) => c.tokens.any(
        (t) => t.type == TokenType.shadow || t.type == TokenType.gradient,
      ),
    );
    return [...collections, if (!has) ?collect(styles)];
  }

  /// The shadows of effect styles and the gradients of fill styles in
  /// [styles], or null when there are none.
  static TokenCollection? collect(List<StyleNode> styles) {
    final tokens = [
      for (final style in styles)
        if (_value(style) case (final type, final value))
          DesignToken(
            path: style.name.split('/').map((s) => s.trim()).toList(),
            type: type,
            values: {_mode: TokenValue(value)},
            description: style.description,
          ),
    ];
    if (tokens.isEmpty) return null;
    return TokenCollection(
      name: collectionName,
      modes: const [_mode],
      tokens: tokens,
    );
  }

  static (TokenType, Object)? _value(StyleNode style) => switch (style.type) {
    'EFFECT' => switch (StyleEffectValues.shadow(style.node)) {
      final shadow? => (TokenType.shadow, shadow),
      null => null,
    },
    'FILL' => switch (StyleEffectValues.gradient(style.node)) {
      final gradient? => (TokenType.gradient, gradient),
      null => null,
    },
    _ => null,
  };
}
