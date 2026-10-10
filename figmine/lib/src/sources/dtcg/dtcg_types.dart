import 'package:figmine/src/sources/dtcg/dtcg_effects.dart';
import 'package:figmine/src/sources/dtcg/dtcg_values.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Maps DTCG types onto figmine token types and parses their values.
abstract final class DtcgTypes {
  /// The figmine type of a DTCG `$type`, or null when unsupported.
  static TokenType? of(String type) => switch (type) {
    'color' => TokenType.color,
    'number' || 'dimension' || 'fontWeight' || 'float' => TokenType.number,
    'string' || 'fontFamily' => TokenType.string,
    'shadow' => TokenType.shadow,
    'gradient' => TokenType.gradient,
    _ => null,
  };

  /// Parses [raw] as a value of [type].
  static Object? parse(TokenType? type, Object? raw) => switch (type) {
    TokenType.color => DtcgValues.color(raw),
    TokenType.number =>
      DtcgValues.number(raw) ?? DtcgValues.weight(raw)?.toDouble(),
    TokenType.string => DtcgValues.string(raw),
    TokenType.shadow => DtcgEffects.shadow(raw),
    TokenType.gradient => DtcgEffects.gradient(raw),
    null => null,
  };
}
