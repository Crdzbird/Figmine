import 'package:figmine/src/inference/color/accent_roles.dart';
import 'package:figmine/src/inference/color/inferred_color.dart';
import 'package:figmine/src/inference/stats/stats_collector.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

Map<String, Object?> _screen(String id, List<Object?> children) =>
    box(id, fill: 0xFFFFFF, width: 400, height: 800, children: children);

void main() {
  test('colors on a dark panel of a light screen are not light ones', () {
    final stats = StatsCollector(
      ScreenSet(
        frames: [
          (
            page: 'App',
            node: _screen('1', [
              box(
                '2',
                fill: 0x322F35,
                width: 344,
                height: 48,
                children: [text('Undo', 0xD0BCFF)],
              ),
              box(
                '3',
                fill: 0x1D1B20,
                width: 40,
                children: [text('Ok', 0xFFFFFF)],
              ),
            ]),
          ),
        ],
      ),
    ).light;
    expect(stats.textCharacters.keys, isNot(contains(0xFFD0BCFF)));
    expect(stats.textCharacters.keys, contains(0xFFFFFFFF));
    expect(stats.backgroundLayers.keys, contains(0xFF322F35));
  });

  test('a pale accent needs three screens, a strong one two', () {
    InferredColor? secondary(int pale, int screens) {
      final frames = [
        for (var i = 0; i < 4; i++)
          (
            page: 'App',
            node: _screen('$i', [
              box('b$i', fill: 0x6750A4, children: [text('Go', 0xFFFFFF)]),
              if (i < screens) box('p$i', fill: pale, width: 80, height: 80),
            ]),
          ),
      ];
      final roles = <String, InferredColor>{};
      final stats = StatsCollector(ScreenSet(frames: frames)).light;
      AccentRoles.infer(roles, stats, 0xFFFFFFFF);
      return roles['secondary'];
    }

    expect(secondary(0xEFB8C8, 2), isNull);
    expect(secondary(0xEFB8C8, 3)?.argb, 0xFFEFB8C8);
    expect(secondary(0x00796B, 2)?.argb, 0xFF00796B);
  });
}
