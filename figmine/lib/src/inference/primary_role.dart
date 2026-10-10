import 'package:figmine/src/inference/accent_roles.dart';
import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Recognizes primary and onPrimary.
abstract final class PrimaryRole {
  /// Adds primary and onPrimary to [roles] and returns primary: the fill
  /// of the default button, gray or colored, when it stands out from the
  /// [surface]; otherwise the most common colored button fill, or the
  /// first of the [ranked] accents, counted in [accents].
  static int? infer(
    Map<String, InferredColor> roles,
    UsageStats s,
    int? surface,
    List<int> ranked,
    Map<int, int> accents,
  ) {
    final base = surface ?? ColorMath.white;
    bool strong(ComponentSample b) =>
        b.fill != null && ColorMath.contrast(b.fill!, base) >= 3;
    final picked = ComponentSamples.select(
      ComponentKind.button,
      s.samples,
      measured: strong,
    ).samples.where(strong);
    final buttons = picked.isNotEmpty
        ? picked.toList()
        : s.samples
              .where((b) => b.kind == ComponentKind.button && b.fill != null)
              .where((b) => AccentRoles.isAccent(b.fill!))
              .toList();
    final fills = <int, int>{};
    for (final button in buttons) {
      UsageStats.count(fills, button.fill!);
    }
    final primary = UsageStats.ranked(fills).firstOrNull ?? ranked.firstOrNull;
    if (primary == null) return null;
    roles['primary'] = fills.isEmpty
        ? (
            argb: primary,
            evidence: 'Most used accent, ${accents[primary]} uses.',
          )
        : (argb: primary, evidence: 'Fill of ${fills[primary]} buttons.');
    final labels = <int, int>{};
    for (final b in buttons.where((b) => b.fill == primary)) {
      if (b.label != null) UsageStats.count(labels, b.label!);
    }
    final label = UsageStats.ranked(labels).firstOrNull;
    roles['onPrimary'] = label == null
        ? (
            argb: ColorMath.readableOn(primary),
            evidence: 'Readable on primary.',
          )
        : (argb: label, evidence: 'Label of ${labels[label]} buttons.');
    return primary;
  }
}
