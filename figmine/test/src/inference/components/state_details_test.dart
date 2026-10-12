import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_state.dart';
import 'package:figmine/src/inference/components/focus_body.dart';
import 'package:figmine/src/inference/components/state_paints.dart';
import 'package:figmine/src/inference/stats/node_facts.dart';
import 'package:figmine/src/inference/stats/node_opacity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

ComponentSample _focus(int fill, {required bool definition}) => (
  kind: ComponentKind.button,
  name: 'button hierarchy=primary, state=focus',
  instance: true,
  definition: definition,
  family: 'button',
  fill: fill,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: 0xFFFFFFFF,
  labelVariable: null,
  radius: 20,
  pill: true,
  height: 40,
  paddingHorizontal: 16,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('layer opacity carries down to the fills it fades', () {
    final group = box('g', children: [box('f', fill: 0x1D1B20)])
      ..['opacity'] = 0.38;
    final flat = NodeOpacity.flatten(group);
    final inner = (flat['children']! as List).single as Map<String, Object?>;
    expect(NodeFacts.fill(inner), 0x611D1B20);
  });

  test('disabled and checked together is its own state', () {
    expect(
      ComponentState.of('state=disabled, checked=true'),
      ComponentState.disabledSelected,
    );
    expect(ComponentState.of('state=focus, checked=true'), isNull);
  });

  test('a focus ring takes the fill of the body it surrounds', () {
    final ring = box(
      'r',
      stroke: 0x1B115C,
      width: 124,
      height: 36,
      children: [box('b', fill: 0x2A4DD3, width: 120, height: 32)],
    );
    expect(NodeFacts.fill(FocusBody.of(ring, ring)), 0xFF2A4DD3);
    final icon = box(
      'r',
      stroke: 0x1B115C,
      width: 124,
      height: 36,
      children: [box('i', fill: 0x2A4DD3, width: 16, height: 16)],
    );
    expect(NodeFacts.fill(FocusBody.of(icon, icon)), isNull);
  });

  test('the component set breaks a tie between placed copies', () {
    final paints = StatePaints.collect([
      _focus(0xFF3567F6, definition: false),
      _focus(0xFF2A4DD3, definition: true),
      for (var i = 0; i < 2; i++) _focus(0xFF3567F6, definition: false),
    ]);
    expect(paints['button.focused.fill']!.argb, 0xFF3567F6);
    final tie = StatePaints.collect([
      _focus(0xFF3567F6, definition: false),
      _focus(0xFF2A4DD3, definition: true),
    ]);
    expect(tie['button.focused.fill']!.argb, 0xFF2A4DD3);
  });
}
