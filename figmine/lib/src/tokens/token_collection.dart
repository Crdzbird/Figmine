import 'package:figmine/src/tokens/design_token.dart';

/// A Figma variable collection, or the color styles of a file.
final class TokenCollection {
  /// Creates a collection.
  const factory({
    required String name,
    required List<String> modes,
    required List<DesignToken> tokens,
  }) = TokenCollection._;

  const new _({required this.name, required this.modes, required this.tokens});

  /// The collection name in Figma.
  final String name;

  /// Mode names, the default mode first.
  final List<String> modes;

  /// Tokens sorted by name.
  final List<DesignToken> tokens;

  /// Whether values differ per mode and need one class per mode.
  bool get multiMode => modes.length > 1;

  /// Returns the token called [name], or null.
  DesignToken? find(String name) {
    for (final token in tokens) {
      if (token.name == name) return token;
    }
    return null;
  }
}
