import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color/accent_roles.dart';
import 'package:figmine/src/inference/color/feedback_roles.dart';
import 'package:figmine/src/inference/color/inferred_collections.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/inference/color/outline_roles.dart';
import 'package:figmine/src/inference/color/surface_roles.dart';
import 'package:figmine/src/inference/components/component_metrics.dart';
import 'package:figmine/src/inference/components/state_paints.dart';
import 'package:figmine/src/inference/inference_result.dart';
import 'package:figmine/src/inference/scales/inferred_layout.dart';
import 'package:figmine/src/inference/scales/typography_inferrer.dart';
import 'package:figmine/src/inference/stats/paint_usage.dart';
import 'package:figmine/src/inference/stats/stats_collector.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';
import 'package:figmine/src/screens/screen_set.dart';

/// Recognizes colors, typography, scales and components in screens.
abstract final class DesignInference {
  /// Analyzes [screens]. Light and dark frames are read separately.
  static InferenceResult analyze(ScreenSet screens, TokensConfig config) {
    final stats = StatsCollector(screens);
    final all = [stats.light, stats.dark];
    final light = _roles(stats.light);
    return InferenceResult(
      frames: screens.frames.length,
      darkScreens: stats.dark.frames,
      colors: InferredCollections.colors(light, _roles(stats.dark), config),
      evidence: (
        roleVariables: {
          for (final role in light.entries)
            role.key: ?stats.light.bindings.mostCommon(
              PaintUsage.of(role.key),
              role.value.argb,
            ),
        },
        colorUses: stats.light.colorUses,
        componentColors: StatePaints.collect(stats.light.samples),
      ),
      layout: InferredLayout.collection(all),
      textStyles: TypographyInferrer.infer([
        for (final s in all) ...s.text.values,
      ]),
      components: ComponentMetrics.infer([for (final s in all) ...s.samples]),
    );
  }

  static Map<String, InferredColor> _roles(UsageStats stats) {
    final roles = <String, InferredColor>{};
    if (stats.frames == 0) return roles;
    final surface = SurfaceRoles.infer(roles, stats);
    AccentRoles.infer(roles, stats, surface);
    FeedbackRoles.infer(roles, stats);
    if (surface != null) OutlineRoles.infer(roles, stats, surface);
    return roles;
  }
}
