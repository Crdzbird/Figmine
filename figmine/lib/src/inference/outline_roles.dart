import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Recognizes outline colors from strokes.
abstract final class OutlineRoles {
  /// Adds outline roles from the strokes of [s] to [roles].
  static void infer(
    Map<String, InferredColor> roles,
    UsageStats s,
    int surface,
  ) {
    final strokes = UsageStats.ranked(s.strokes)
        .where((c) => ColorMath.contrast(c, surface) >= 1.1)
        .toList();
    final outline = strokes.firstOrNull;
    if (outline == null) return;
    roles['outline'] = (
      argb: outline,
      evidence: 'Most used stroke, ${s.strokes[outline]} layers.',
    );
    final strength = ColorMath.contrast(outline, surface);
    final variant = strokes
        .skip(1)
        .where((c) => ColorMath.contrast(c, surface) < strength)
        .firstOrNull;
    if (variant == null) return;
    roles['outlineVariant'] = (
      argb: variant,
      evidence: 'Subtle stroke, ${s.strokes[variant]} layers.',
    );
  }
}
