import 'package:figmine/src/codegen/derive/seed_scheme.dart';
import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color/feedback_roles.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Turns recognized color roles into a light and dark collection.
abstract final class InferredCollections {
  /// Name of the inferred color collection.
  static const String colorsName = 'Inferred colors';

  /// Colors in light and dark mode. A mode without screens is derived from
  /// the primary color of the other one, while secondary, tertiary, error
  /// and feedback colors keep their own hue at the Material tone of that
  /// mode.
  static TokenCollection? colors(
    Map<String, InferredColor> light,
    Map<String, InferredColor> dark,
    TokensConfig config,
  ) {
    if (light.isEmpty && dark.isEmpty) return null;
    final seed = (light['primary'] ?? dark['primary'])?.argb;
    final derivedLight = SeedScheme.derive(
      seed ?? SeedScheme.baseline,
      dark: false,
    );
    final derivedDark = SeedScheme.derive(
      seed ?? SeedScheme.baseline,
      dark: true,
    );
    final modes = [config.lightMode, config.darkMode];
    final tokens = <DesignToken>[];
    for (final role in [...MaterialRoles.colorScheme, ...FeedbackRoles.names]) {
      final seen = light[role] ?? dark[role];
      if (seen == null) continue;
      final note = light[role] == null
          ? ' The light value is derived from primary.'
          : (dark[role] == null
                ? ' The dark value is derived from primary.'
                : '');
      tokens.add(
        DesignToken(
          path: [role],
          type: TokenType.color,
          description: 'Inferred from the screens. ${seen.evidence}$note',
          values: {
            modes.first: _value(
              light[role]?.argb ?? derivedLight[role] ?? _tone(seen.argb, 40),
            ),
            modes.last: _value(
              dark[role]?.argb ??
                  (_ownHue.contains(role) && light[role] != null
                      ? _tone(light[role]!.argb, 80)
                      : null) ??
                  derivedDark[role] ??
                  _tone(seen.argb, 80),
            ),
          },
        ),
      );
    }
    return TokenCollection(name: colorsName, modes: modes, tokens: tokens);
  }

  static TokenValue _value(int argb) => TokenValue(ColorValue.fromArgb(argb));

  /// Accent roles that keep their own hue in a derived dark mode.
  static const Set<String> _ownHue = {'secondary', 'tertiary', 'error'};

  /// [argb] at [tone], the tone Material gives such colors: 40 in light
  /// mode and 80 in dark mode.
  static int _tone(int argb, double tone) {
    final hct = Hct.fromInt(argb);
    return Hct.from(hct.hue, hct.chroma, tone).toInt();
  }
}
