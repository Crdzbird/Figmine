import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_samples.dart';
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
    final outline = _fieldStroke(strokes, s, surface) ?? strokes.firstOrNull;
    if (outline == null) return;
    roles['outline'] = (
      argb: outline,
      evidence: 'Most used stroke, ${s.strokes[outline]} layers.',
    );
    final strength = ColorMath.contrast(outline, surface);
    final variant = strokes
        .where((c) => c != outline)
        .where((c) => ColorMath.contrast(c, surface) < strength)
        .firstOrNull;
    if (variant == null) return;
    roles['outlineVariant'] = (
      argb: variant,
      evidence: 'Subtle stroke, ${s.strokes[variant]} layers.',
    );
  }

  /// The resting text field stroke, when the most used stroke is below 2:1
  /// against [surface], a divider, and the fields use a stronger one.
  static int? _fieldStroke(List<int> strokes, UsageStats s, int surface) {
    final top = strokes.firstOrNull;
    if (top == null || ColorMath.contrast(top, surface) >= 2) return null;
    final fields = ComponentSamples.select(ComponentKind.input, s.samples);
    final counts = <int, int>{};
    for (final stroke in fields.samples.map((f) => f.stroke).nonNulls) {
      UsageStats.count(counts, stroke);
    }
    final field = UsageStats.ranked(counts).firstOrNull;
    if (field == null || !strokes.contains(field)) return null;
    final stronger =
        ColorMath.contrast(field, surface) > ColorMath.contrast(top, surface);
    return stronger ? field : null;
  }
}
