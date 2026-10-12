import 'package:figmine/src/codegen/scheme/overlay_fit.dart';
import 'package:figmine/src/inference/components/component_state.dart';
import 'package:figmine/src/inference/components/state_paints.dart';
import 'package:figmine/src/inference/stats/stats_collector.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

void main() {
  test('variant names give one state, or none when they combine two', () {
    expect(
      ComponentState.of('Button State=Hover, Size=M'),
      ComponentState.hovered,
    );
    expect(ComponentState.of('state=idle, error=yes'), ComponentState.error);
    expect(ComponentState.of('Status=Pressed'), ComponentState.pressed);
    expect(ComponentState.of('disabled=true'), ComponentState.disabled);
    expect(ComponentState.of('selected=on'), ComponentState.selected);
    expect(ComponentState.of('Variant=Primary'), ComponentState.enabled);
    expect(ComponentState.of('state=focus, error=yes'), isNull);
  });

  test('overlay fits recover the opacity and blend back', () {
    final hovered = OverlayFit.blend(0xFF2C2C2C, 0xFF000000, 0.3);
    final (opacity, miss) = OverlayFit.fit(0xFF2C2C2C, 0xFF000000, hovered);
    expect(opacity, closeTo(0.3, 0.02));
    expect(miss, lessThan(0.01));
  });

  test('component set variants give the colors of each state', () {
    Map<String, Object?> variant(String id, String state, int fill) => box(
      id,
      type: 'COMPONENT',
      name: 'Variant=Primary, State=$state, Size=Medium',
      fill: fill,
      radius: 8,
      children: [text('Button', 0xF5F5F5)],
    );
    final stats = StatsCollector(
      ScreenSet(
        frames: [
          (
            page: 'Components',
            node: box(
              'set',
              type: 'COMPONENT_SET',
              name: 'Button',
              children: [
                for (var i = 0; i < 3; i++) variant('d$i', 'Default', 0x2C2C2C),
                for (var i = 0; i < 3; i++) variant('h$i', 'Hover', 0x1E1E1E),
                for (var i = 0; i < 3; i++)
                  variant('x$i', 'Disabled', 0xD9D9D9),
              ],
            ),
          ),
        ],
      ),
    );
    final paints = StatePaints.collect(stats.light.samples);
    expect(paints['button.enabled.fill']!.argb, 0xFF2C2C2C);
    expect(paints['button.hovered.fill']!.argb, 0xFF1E1E1E);
    expect(paints['button.disabled.fill']!.argb, 0xFFD9D9D9);
    expect(paints['button.enabled.label']!.argb, 0xFFF5F5F5);
  });
}
