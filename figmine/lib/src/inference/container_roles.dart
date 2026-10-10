import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Recognizes surface containers and the inverse surface.
abstract final class ContainerRoles {
  static const List<String> _containers = [
    'surfaceContainerLow',
    'surfaceContainer',
    'surfaceContainerHigh',
    'surfaceContainerHighest',
  ];

  /// Adds containers from the backgrounds of [s] that stay close to
  /// [surface], on the side away from the text, from the closest, and the
  /// inverse surface from the [neutral] ones.
  static void infer(
    Map<String, InferredColor> roles,
    UsageStats s,
    List<int> neutral,
    int surface,
  ) {
    final lightMode = ColorMath.luminance(surface) >= 0.2;
    bool beyond(int c) => lightMode
        ? ColorMath.luminance(c) < ColorMath.luminance(surface)
        : ColorMath.luminance(c) > ColorMath.luminance(surface);
    final subtle =
        UsageStats.ranked(s.backgroundArea)
            .where((c) => c != surface && beyond(c))
            .where((c) => ColorMath.contrast(c, surface) < 2)
            .where((c) => s.frames < 3 || (s.colorFrames[c]?.length ?? 0) >= 3)
            .where((c) => _samePalette(c, surface))
            .fold(<int>[], (kept, c) => _apart(kept, c) ? [...kept, c] : kept)
          ..sort(
            (a, b) => ColorMath.contrast(
              a,
              surface,
            ).compareTo(ColorMath.contrast(b, surface)),
          );
    for (var i = 0; i < subtle.length && i < _containers.length; i++) {
      roles[_containers[i]] = (
        argb: subtle[i],
        evidence:
            'Neutral background, ${s.backgroundLayers[subtle[i]]} layers.',
      );
    }
    final inverse = neutral
        .where((c) => ColorMath.contrast(c, surface) >= 7)
        .firstOrNull;
    if (inverse != null) {
      roles['inverseSurface'] = (
        argb: inverse,
        evidence:
            'High contrast background, '
            '${s.backgroundLayers[inverse]} layers.',
      );
      roles['onInverseSurface'] = (
        argb: ColorMath.readableOn(inverse),
        evidence: 'Readable color on the inverse surface.',
      );
    }
  }

  /// Whether [c] is at least 1.5 tones from every color in [kept], which
  /// cover more area, as Material container steps are two tones apart and
  /// closer ones are state tints.
  static bool _apart(List<int> kept, int c) {
    final tone = Hct.fromInt(c).tone;
    return kept.every((k) => (Hct.fromInt(k).tone - tone).abs() >= 1.5);
  }

  /// Whether [c] comes from the neutral palette of [surface]: a gray for a
  /// gray surface, or for a tinted one, the same hue at a similar tint, as
  /// Material derives every surface from one palette.
  static bool _samePalette(int c, int surface) {
    final color = Hct.fromInt(c);
    final base = Hct.fromInt(surface);
    if (base.chroma < 4) return color.chroma < 4;
    final turn = (color.hue - base.hue).abs() % 360;
    final hue = turn > 180 ? 360 - turn : turn;
    return color.chroma >= 4 && color.chroma <= 10 && hue <= 30;
  }
}
