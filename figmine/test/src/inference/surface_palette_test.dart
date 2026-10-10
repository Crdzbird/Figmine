import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/surface_roles.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:flutter_test/flutter_test.dart';

UsageStats _stats(Map<int, double> areas, {int board = 0xFFF5F5F5}) {
  final s = UsageStats()
    ..frames = 10
    ..frameFills[board] = 10;
  for (final MapEntry(key: c, value: share) in areas.entries) {
    s.backgroundArea[c] = share * 1000;
    s.totalArea += share * 1000;
    s.colorFrames[c] = {0, 1, 2, 3};
  }
  s.textCharacters[0xFF1D1B20] = 100;
  return s;
}

Map<String, int> _roles(UsageStats s) {
  final roles = <String, InferredColor>{};
  SurfaceRoles.infer(roles, s);
  return {for (final e in roles.entries) e.key: e.value.argb};
}

void main() {
  test('a tinted surface drawn on a gray board, with its palette', () {
    final roles = _roles(
      _stats({
        0xFFF5F5F5: 0.71,
        0xFFFEF7FF: 0.063,
        0xFFF3EDF7: 0.05,
        0xFFF5EFF7: 0.01,
        0xFFF7F2FA: 0.012,
        0xFFECE6F0: 0.021,
        0xFFE6E0E9: 0.006,
        0xFFFCEEEE: 0.004,
      }),
    );
    expect(roles['surface'], 0xFFFEF7FF);
    expect(roles['surfaceContainerLow'], 0xFFF7F2FA);
    expect(roles['surfaceContainer'], 0xFFF3EDF7);
    expect(roles['surfaceContainerHigh'], 0xFFECE6F0);
    expect(roles['surfaceContainerHighest'], 0xFFE6E0E9);
  });

  test('a white app surface keeps gray containers', () {
    final roles = _roles(
      _stats({
        0xFFFFFFFF: 0.6,
        0xFFF5F5F5: 0.3,
        0xFFE3E3E3: 0.05,
      }, board: 0xFFFFFFFF),
    );
    expect(roles['surface'], 0xFFFFFFFF);
    expect(roles['surfaceContainerLow'], 0xFFF5F5F5);
    expect(roles['surfaceContainer'], 0xFFE3E3E3);
  });
}
