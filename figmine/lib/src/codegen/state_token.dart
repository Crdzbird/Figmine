import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/state_dark.dart';
import 'package:figmine/src/codegen/state_fallback.dart';
import 'package:figmine/src/codegen/state_field_specs.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/state_paints.dart';
import 'package:figmine/src/sources/collection_modes.dart';

/// Builds a state field from the variable bound in the Figma variant.
abstract final class StateToken {
  /// The field of [spec] referencing [token], with a derived dark value
  /// for single mode tokens. Drawn at another opacity than the token, it
  /// becomes the token's light and dark colors at that opacity, as a token
  /// reference would drop it.
  static SchemeField field(
    StateSpec spec,
    StatePaint paint,
    ColorCandidate token,
    Map<String, SchemeField> by,
    TokenIndex index,
    TokensConfig tokens,
  ) {
    final variant = '`${spec.key.split('.')[1]}` variant';
    final base = SchemeFieldBuilders.field(spec.name, token, index, tokens);
    final modes = CollectionModes.pick(token.collection.modes, tokens);
    final field = modes.light != modes.dark
        ? base
        : StateDark.apply(spec, base, by, '${base.doc} Bound in the $variant.');
    final alpha = ColorMath.alpha(paint.argb);
    if ((alpha - ColorMath.alpha(field.lightArgb)).abs() < 0.01) return field;
    final a = (alpha * 255).round() << 24;
    final light = a | field.lightArgb & 0xFFFFFF;
    final dark = a | field.darkArgb & 0xFFFFFF;
    return (
      name: spec.name,
      doc:
          '`${token.token.name}` at ${(alpha * 100).round()}% in the $variant.',
      light: StateFallback.literal(light),
      dark: StateFallback.literal(dark),
      lightArgb: light,
      darkArgb: dark,
    );
  }
}
