import 'package:figmine/src/codegen/scheme/color_candidates.dart';
import 'package:figmine/src/codegen/scheme/role_ramp.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// Finds the role scales of a design, such as `primary/10` to `primary/100`.
abstract final class RoleRamps {
  /// Group names that mark the scale of each family, preferred in order.
  static const Map<String, List<String>> families = {
    'primary': ['primary', 'brand'],
    'secondary': ['secondary'],
    'tertiary': ['tertiary', 'accent'],
    'error': ['error', 'danger', 'critical', 'destructive', 'red'],
    'neutral': ['neutral', 'gray', 'grey'],
    'success': ['success', 'positive', 'green'],
    'warning': ['warning', 'caution', 'yellow', 'amber', 'orange'],
    'info': ['info', 'information'],
  };

  /// The scale of each family among [all]: color tokens whose last segment
  /// is a number and whose parent group names the family. Scales need five
  /// resolved steps; the preferred group name wins, then the longest scale,
  /// then the shortest path.
  static Map<String, RoleRamp> find(List<ColorCandidate> all) {
    final groups = <String, List<ColorCandidate>>{};
    for (final candidate in all) {
      final path = candidate.token.path;
      if (path.length < 2 || int.tryParse(path.last) == null) continue;
      if (candidate.token.values.values.first.value is! ColorValue) continue;
      if (_family(path) == null) continue;
      final group = path.sublist(0, path.length - 1).join('/');
      (groups['${candidate.collection.name}|$group'] ??= []).add(candidate);
    }
    final ramps = <String, RoleRamp>{};
    for (final steps in groups.values.where((g) => g.length >= 5)) {
      steps.sort((a, b) => _step(a).compareTo(_step(b)));
      final (family, rank) = _family(steps.first.token.path)!;
      if (!_wins(steps, rank, ramps[family])) continue;
      ramps[family] = RoleRamp(family: family, steps: steps);
    }
    return ramps;
  }

  /// The family of a Material or extra [role], such as `tertiary` for
  /// `onTertiaryContainer`, `primary` for `inversePrimary` and `neutral`
  /// for surfaces and outlines.
  static String? familyOf(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('surface') || lower.startsWith('outline')) {
      return 'neutral';
    }
    for (final family in families.keys) {
      if (lower.startsWith(family) ||
          lower.startsWith('on$family') ||
          lower == 'inverse$family') {
        return family;
      }
    }
    return null;
  }

  static (String, int)? _family(List<String> path) {
    final group = path[path.length - 2].toLowerCase();
    for (final entry in families.entries) {
      final rank = entry.value.indexOf(group);
      if (rank >= 0) return (entry.key, rank);
    }
    return null;
  }

  static bool _wins(List<ColorCandidate> steps, int rank, RoleRamp? than) {
    if (than == null) return true;
    final path = than.steps.first.token.path;
    final before = _family(path)!.$2;
    if (rank != before) return rank < before;
    if (steps.length != than.steps.length) {
      return steps.length > than.steps.length;
    }
    return steps.first.token.path.length < path.length;
  }

  static int _step(ColorCandidate c) => int.parse(c.token.path.last);
}
