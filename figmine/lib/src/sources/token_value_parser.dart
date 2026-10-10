import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/curve_value.dart';
import 'package:figmine/src/tokens/duration_value.dart';
import 'package:figmine/src/tokens/font_weight_value.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Converts raw Figma values into token values.
abstract final class TokenValueParser {
  /// Returns the value of [type] that [raw] holds, or null when it holds
  /// none.
  static Object? parse(Object? raw, TokenType type) => switch (type) {
    TokenType.color => ColorValue.tryParse(raw),
    TokenType.number => raw is num ? raw.toDouble() : null,
    TokenType.string => raw is String ? raw : null,
    TokenType.boolean => raw is bool ? raw : null,
    TokenType.duration => DurationValue.tryParse(raw),
    TokenType.curve => CurveValue.tryParse(raw),
    TokenType.fontWeight => FontWeightValue.tryParse(raw),
    TokenType.shadow || TokenType.gradient => null,
  };
}
