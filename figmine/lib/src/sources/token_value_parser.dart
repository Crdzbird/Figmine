import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Converts raw Figma values into token values.
abstract final class TokenValueParser {
  /// Returns a `ColorValue`, `double` or `String`, or null when [raw] does
  /// not match [type].
  static Object? parse(Object? raw, TokenType type) => switch (type) {
    TokenType.color => ColorValue.tryParse(raw),
    TokenType.number => raw is num ? raw.toDouble() : null,
    TokenType.string => raw is String ? raw : null,
    TokenType.shadow || TokenType.gradient => null,
  };
}
