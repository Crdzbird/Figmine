import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/container_roles.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Recognizes surfaces and text colors.
abstract final class SurfaceRoles {
  /// Whether [argb] is a gray rather than a hue: perceptual chroma up to
  /// 6, the most Material neutral palettes use. Pale tints of a hue, such
  /// as a light green, are not neutral.
  static bool isNeutral(int argb) => Hct.fromInt(argb).chroma <= 6;

  /// Adds the surface roles found in [s] to [roles]. Returns the surface.
  static int? infer(Map<String, InferredColor> roles, UsageStats s) {
    final backgrounds = UsageStats.ranked(s.backgroundArea);
    final neutral = backgrounds.where(isNeutral).toList();
    final surface = _surface(neutral, s) ?? backgrounds.firstOrNull;
    if (surface == null) return null;
    final share = s.totalArea == 0
        ? 0
        : (s.backgroundArea[surface]! / s.totalArea * 100).round();
    roles['surface'] = (
      argb: surface,
      evidence: 'Largest background, $share% of the filled area.',
    );
    final texts = UsageStats.ranked(s.textCharacters);
    final onSurface =
        texts.where((c) => ColorMath.contrast(c, surface) >= 4.5).firstOrNull ??
        texts.firstOrNull;
    if (onSurface != null) {
      roles['onSurface'] = (
        argb: onSurface,
        evidence:
            'Most used text color, '
            '${s.textCharacters[onSurface]} characters.',
      );
    }
    final main = onSurface == null
        ? 21
        : ColorMath.contrast(onSurface, surface);
    final variant = texts
        .where((c) => c != onSurface && isNeutral(c))
        .map((c) => (c, ColorMath.contrast(c, surface)))
        .where((e) => e.$2 >= 3 && e.$2 < main)
        .firstOrNull
        ?.$1;
    if (variant != null) {
      roles['onSurfaceVariant'] = (
        argb: variant,
        evidence:
            'Secondary text color, ${s.textCharacters[variant]} characters.',
      );
    }
    ContainerRoles.infer(roles, s, neutral, surface);
    return surface;
  }

  /// The lightest neutral background covering a fifth of the area, or the
  /// darkest when the largest one is dark: the base the others sit on.
  static int? _surface(List<int> neutral, UsageStats s) {
    final major = neutral
        .where((c) => s.backgroundArea[c]! >= s.totalArea * 0.2)
        .toList();
    if (major.isEmpty) return neutral.firstOrNull;
    final dark = ColorMath.luminance(major.first) < 0.2;
    return major.reduce((a, b) {
      final lighter = ColorMath.luminance(b) > ColorMath.luminance(a);
      return lighter != dark ? b : a;
    });
  }
}
