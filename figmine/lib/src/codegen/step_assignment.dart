import 'package:figmine/src/codegen/color_candidates.dart';
import 'package:figmine/src/codegen/role_ramp.dart';
import 'package:figmine/src/codegen/role_ramps.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Matches derived colors of one mode to scale steps, one step per color,
/// so that roles with different tones, such as the surface containers,
/// never collapse onto the same step.
abstract final class StepAssignment {
  /// The step chosen for each derived color of [roles], by family and then
  /// by color, leaving out the roles in [skip]. Colors without a close free
  /// step are absent.
  static Map<String, Map<int, ColorCandidate>> assign(
    Map<String, int> roles,
    Map<String, RoleRamp> ramps, {
    Set<String> skip = const {},
    double tolerance = 6,
  }) {
    final result = <String, Map<int, ColorCandidate>>{};
    for (final entry in ramps.entries) {
      final assigned = result[entry.key] = <int, ColorCandidate>{};
      final colors = {
        for (final role in roles.entries)
          if (!skip.contains(role.key) &&
              RoleRamps.familyOf(role.key) == entry.key)
            role.value,
      };
      final pairs = [
        for (final color in colors)
          for (final step in entry.value.steps)
            (color, step, _distance(color, RoleRamp.argb(step))),
      ]..sort((a, b) => a.$3.compareTo(b.$3));
      final used = <String>{};
      for (final (color, step, distance) in pairs) {
        if (distance > tolerance) break;
        if (assigned.containsKey(color) || used.contains(step.token.name)) {
          continue;
        }
        assigned[color] = step;
        used.add(step.token.name);
      }
    }
    return result;
  }

  static double _distance(int a, int b) =>
      (Hct.fromInt(a).tone - Hct.fromInt(b).tone).abs();
}
