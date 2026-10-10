import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Pairs color styles such as `light/primary` and `dark/primary`.
final class StyleModeGrouper {
  /// Creates an empty grouper.
  factory(TokensConfig config) = StyleModeGrouper._;

  new _(this.config);

  /// Token settings with the light and dark folder names.
  final TokensConfig config;

  final Map<String, ({List<String> path, String description})> _tokens = {};
  final Map<String, ColorValue> _light = {};
  final Map<String, ColorValue> _dark = {};
  final Map<String, ColorValue> _shared = {};

  /// Adds the style called [name] with [color].
  void add(String name, ColorValue color, String description) {
    final segments = name.split('/').map((s) => s.trim()).toList();
    final folder = segments.first.toLowerCase();
    final nested = segments.length > 1;
    final isLight = nested && folder == config.lightMode.toLowerCase();
    final isDark = nested && folder == config.darkMode.toLowerCase();
    final path = config.pathOf(
      isLight || isDark ? segments.skip(1).join('/') : name,
    );
    if (path.isEmpty) return;
    final key = path.join('/');
    _tokens.putIfAbsent(key, () => (path: path, description: description));
    (isLight ? _light : (isDark ? _dark : _shared)).putIfAbsent(
      key,
      () => color,
    );
  }

  /// Returns the styles as one collection, or null without styles.
  TokenCollection? collection(String name) {
    if (_tokens.isEmpty) return null;
    final paired = _light.isNotEmpty || _dark.isNotEmpty;
    final modes = paired ? [config.lightMode, config.darkMode] : ['Default'];
    final keys = _tokens.keys.toList()..sort();
    return TokenCollection(
      name: name,
      modes: modes,
      tokens: [for (final key in keys) _token(key, modes, paired)],
    );
  }

  DesignToken _token(String key, List<String> modes, bool paired) {
    final light = _light[key] ?? _shared[key] ?? _dark[key]!;
    final dark = _dark[key] ?? _shared[key] ?? light;
    return DesignToken(
      path: _tokens[key]!.path,
      type: TokenType.color,
      description: _tokens[key]!.description,
      values: paired
          ? {modes.first: TokenValue(light), modes.last: TokenValue(dark)}
          : {modes.first: TokenValue(light)},
    );
  }
}
