import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/inference/feedback_roles.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/primary_role.dart';
import 'package:figmine/src/inference/usage_stats.dart';

/// Recognizes primary, secondary, tertiary and error colors.
abstract final class AccentRoles {
  /// Whether [argb] is colorful enough to be an accent.
  static bool isAccent(int argb) => ColorMath.chroma(argb) >= 0.2;

  /// Adds the accent roles found in [s] to [roles].
  ///
  /// Primary is the fill of the default button, gray or colored, when it
  /// stands out from the surface; otherwise the most common colored button
  /// fill, or the most used accent.
  /// Secondary and tertiary stay out of the hues of error, success and
  /// warning colors, skip pale tints, which serve as containers, and need
  /// several screens when they are pale.
  /// Accents found on a single screen, such as annotation colors on a
  /// documentation board, do not count when there are three or more.
  static void infer(
    Map<String, InferredColor> roles,
    UsageStats s,
    int? surface,
  ) {
    final accents = <int, int>{};
    for (final e in s.backgroundLayers.entries.where((e) => isAccent(e.key))) {
      UsageStats.count(accents, e.key, e.value);
    }
    for (final e in s.textCharacters.entries.where((e) => isAccent(e.key))) {
      UsageStats.count(accents, e.key, (e.value / 20).ceil());
    }
    final ranked = UsageStats.ranked(accents)
      ..remove(surface)
      ..removeWhere(
        (c) => s.frames >= 3 && (s.colorFrames[c]?.length ?? 0) < 2,
      );
    final primary = PrimaryRole.infer(roles, s, surface, ranked, accents);
    if (primary == null) return;
    final error = ranked
        .where((c) => c != primary && _isRed(c) && ColorMath.chroma(c) >= 0.3)
        .firstOrNull;
    final feedback = [
      ?error,
      ...FeedbackRoles.candidates(
        ranked.where((c) => c != primary),
        surface ?? ColorMath.white,
      ).values,
    ];
    final others = ranked
        .where((c) => c != error && ColorMath.distinct(c, primary))
        .where((c) => feedback.every((f) => ColorMath.hueDistance(c, f) >= 20))
        .where((c) => _stands(c, surface ?? ColorMath.white, s))
        .toList();
    final secondary = others.firstOrNull;
    final tertiary = others
        .where((c) => secondary != null && ColorMath.distinct(c, secondary))
        .firstOrNull;
    for (final (role, color) in [
      ('secondary', secondary),
      ('tertiary', tertiary),
      ('error', error),
    ]) {
      if (color == null) continue;
      roles[role] = (argb: color, evidence: 'Accent, ${accents[color]} uses.');
      final on = 'on${role[0].toUpperCase()}${role.substring(1)}';
      roles[on] = (
        argb: ColorMath.readableOn(color),
        evidence: 'Readable on $role.',
      );
    }
  }

  /// Whether [c] stands out from [surface] as an accent: 3:1, the
  /// minimum for UI components, or a paler color that recurs on at least
  /// three screens, as pale tones on one or two screens are usually
  /// swatches or examples of another mode.
  static bool _stands(int c, int surface, UsageStats s) {
    final contrast = ColorMath.contrast(c, surface);
    if (contrast >= 3) return true;
    return contrast >= 1.5 && (s.colorFrames[c]?.length ?? 0) >= 3;
  }

  static bool _isRed(int argb) {
    final hue = ColorMath.hue(argb);
    return hue >= 345 || hue <= 20;
  }
}
