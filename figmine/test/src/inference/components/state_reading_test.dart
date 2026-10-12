import 'package:figmine/src/inference/components/component_body.dart';
import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_state.dart';
import 'package:figmine/src/inference/components/state_paints.dart';
import 'package:figmine/src/score/score_item.dart';
import 'package:figmine/src/score/scorer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

ComponentSample _tab(String family, String name, int label) => (
  kind: ComponentKind.tab,
  name: '$family $name',
  instance: true,
  definition: false,
  family: family,
  fill: 0xFFFEF7FF,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: label,
  labelVariable: null,
  radius: null,
  pill: false,
  height: 48,
  paddingHorizontal: null,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('error values name the state whatever the key', () {
    expect(
      ComponentState.of('type=error unselected, state=enabled'),
      ComponentState.error,
    );
    expect(ComponentState.of('type=error unselected'), ComponentState.error);
    expect(ComponentState.stated('selected=false, state=enabled'), isTrue);
    expect(
      ComponentState.stated('configuration=fixed, style=primary'),
      isFalse,
    );
  });

  test('state colors come from variants that name their state', () {
    final paints = StatePaints.collect([
      for (var i = 0; i < 6; i++) _tab('tabs', 'style=primary', 0xFF6750A4),
      for (final family in [
        'primary tabs/a',
        'primary tabs/b',
        'primary tabs/c',
      ])
        _tab(family, 'selected=false, state=enabled', 0xFF49454F),
      _tab('.building blocks/tab', 'state=enabled', 0xFFFF0000),
    ]);
    expect(paints['tab.enabled.label']!.argb, 0xFF49454F);
  });

  test('a modal body skips its scrim', () {
    final scrim = box('s', fill: 0x000000, width: 400, height: 800);
    ((scrim['fills']! as List).single as Map)['opacity'] = 0.32;
    final sheet = box(
      '1',
      width: 400,
      height: 800,
      children: [scrim, box('p', fill: 0xF7F2FA, width: 400, height: 300)],
    );
    expect(ComponentBody.of(sheet)!['id'], 's');
    expect(ComponentBody.of(sheet, opaque: true)!['id'], 'p');
  });

  test('translucent colors are graded as seen on the surface', () {
    final items = Scorer.grade(
      (
        light: {'surface': 0xFFFFFFFF, 'hover': 0x146750A4},
        dark: const {},
        components: const {},
        text: const {},
      ),
      (
        light: {'surface': 0xFFFFFFFF, 'hover': 0xFF6750A4},
        dark: const {},
        components: const {},
        text: const {},
      ),
    );
    expect(items.last.grade, Grade.off);
  });
}
