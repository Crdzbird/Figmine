import 'package:figmine/src/inference/color/accent_roles.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';

/// Recognizes success and warning colors among the accents of screens.
abstract final class FeedbackRoles {
  /// Extra roles figmine recognizes beyond the Material ColorScheme.
  static const List<String> names = ['success', 'warning', 'info'];

  /// Adds `success` (greens) and `warning` (oranges and ambers) found in
  /// [s] that no other role took. Pale tints, which serve as containers,
  /// are skipped: the role needs 3:1 against the surface.
  static void infer(Map<String, InferredColor> roles, UsageStats s) {
    final taken = roles.values.map((r) => r.argb).toSet();
    final uses = s.colorUses;
    final found = candidates(
      UsageStats.ranked(uses).where((c) => !taken.contains(c)),
      roles['surface']?.argb ?? ColorMath.white,
    );
    for (final entry in found.entries) {
      roles[entry.key] = (
        argb: entry.value,
        evidence: 'Feedback accent, ${uses[entry.value]} uses.',
      );
    }
  }

  /// The first green and the first orange or amber among [ranked] colors
  /// that are accents with 3:1 contrast against [surface], by role.
  static Map<String, int> candidates(Iterable<int> ranked, int surface) {
    final usable = ranked
        .where(AccentRoles.isAccent)
        .where((c) => ColorMath.contrast(c, surface) >= 3)
        .toList();
    return {
      for (final (role, low, high) in const [
        ('success', 85.0, 165.0),
        ('warning', 25.0, 55.0),
      ])
        role: ?usable.where((c) {
          final hue = ColorMath.hue(c);
          return hue >= low && hue <= high;
        }).firstOrNull,
    };
  }
}
