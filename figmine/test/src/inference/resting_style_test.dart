import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/resting_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a button style is judged on its resting variant', () {
    ComponentSample text(String state, {int? fill, int? stroke}) => (
      kind: ComponentKind.button,
      name: 'button variant=subtle, state=$state, size=medium',
      instance: true,
      definition: true,
      family: 'button',
      fill: fill,
      fillVariable: null,
      stroke: stroke,
      strokeVariable: null,
      label: 0xFF303030,
      labelVariable: null,
      radius: 8,
      pill: false,
      height: 40,
      paddingHorizontal: 12,
      padding: null,
      shadow: 0,
      mark: null,
      markVariable: null,
    );
    final kept = RestingStyle.filter([
      text('default'),
      text('hover', stroke: 0xFFD9D9D9),
      text('disabled', fill: 0xFFD9D9D9),
    ], (s) => s.fill == null && s.stroke == null);
    expect(kept, hasLength(3));
  });
}
