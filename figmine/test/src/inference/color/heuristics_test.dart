import 'package:figmine/src/inference/color/accent_roles.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/inference/color/outline_roles.dart';
import 'package:figmine/src/inference/color/surface_roles.dart';
import 'package:figmine/src/inference/stats/stats_collector.dart';
import 'package:figmine/src/inference/stats/usage_stats.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

const _white = 0xFFFFFFFF;

UsageStats _stats() => UsageStats()
  ..frames = 1
  ..backgroundArea[_white] = 1000
  ..totalArea = 1000;

void main() {
  test('secondary text is softer than the main text, never black', () {
    final stats = _stats()
      ..textCharacters.addAll({
        0xFF1B115C: 900,
        0xFF000000: 300,
        0xFF5E5E5E: 100,
      });
    final roles = <String, InferredColor>{};
    SurfaceRoles.infer(roles, stats);
    expect(roles['onSurface']!.argb, 0xFF1B115C);
    expect(roles['onSurfaceVariant']!.argb, 0xFF5E5E5E);
  });

  test('invisible strokes never become outlines', () {
    final stats = _stats()
      ..strokes.addAll({_white: 900, 0xFF9D9D9D: 500, 0xFFE0E0E0: 100});
    final roles = <String, InferredColor>{};
    OutlineRoles.infer(roles, stats, _white);
    expect(roles['outline']!.argb, 0xFF9D9D9D);
    expect(roles['outlineVariant']!.argb, 0xFFE0E0E0);
  });

  test('feedback hues are not used as secondary or tertiary', () {
    final stats = _stats()
      ..backgroundLayers.addAll({
        0xFF3567F6: 50,
        0xFFD40E14: 40,
        0xFFC7152A: 30,
        0xFF1C875B: 20,
      });
    final roles = <String, InferredColor>{};
    AccentRoles.infer(roles, stats, _white);
    expect(roles['error']!.argb, 0xFFD40E14);
    expect(roles.containsKey('secondary'), isFalse);
    expect(roles.containsKey('tertiary'), isFalse);
  });

  test('a few dark sections do not create a dark mode', () {
    ScreenFrame frame(String name, int fill) =>
        (page: 'App', node: box(name, name: name, fill: fill));
    final few = StatsCollector(
      ScreenSet(
        frames: [
          for (var i = 0; i < 9; i++) frame('Screen $i', 0xFFFFFF),
          frame('Footer', 0x111111),
        ],
      ),
    );
    expect(few.dark.frames, 0);
    final named = StatsCollector(
      ScreenSet(
        frames: [frame('Home', 0xFFFFFF), frame('Home Dark', 0xFFFFFF)],
      ),
    );
    expect(named.dark.frames, 1);
  });
}
