import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Recognizes surface containers and the inverse surface.
abstract final class ContainerRoles {
  static const List<String> _containers = [
    'surfaceContainerLow',
    'surfaceContainer',
    'surfaceContainerHigh',
    'surfaceContainerHighest',
  ];

  /// Adds containers from the [neutral] backgrounds of [s] that stay
  /// close to [surface], from the closest, and the inverse surface.
  static void infer(
    Map<String, InferredColor> roles,
    UsageStats s,
    List<int> neutral,
    int surface,
  ) {
    final subtle =
        neutral
            .where((c) => c != surface && ColorMath.contrast(c, surface) < 2)
            .toList()
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
}
