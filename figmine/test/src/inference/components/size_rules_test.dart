import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_samples.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentSample _button(
  String family,
  String size,
  double height, {
  bool definition = false,
}) => (
  kind: ComponentKind.button,
  name: '$family size=$size',
  instance: true,
  definition: definition,
  family: family,
  fill: 0xFF6750A4,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: 0xFFFFFFFF,
  labelVariable: null,
  radius: 20,
  pill: true,
  height: height,
  paddingHorizontal: 16,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('the component named for the kind beats its variations', () {
    final picked = ComponentSamples.select(ComponentKind.button, [
      for (var i = 0; i < 9; i++) _button('split button', 'xsmall', 32),
      for (var i = 0; i < 4; i++) _button('button', 'small', 40),
    ]);
    expect(picked.samples.map((s) => s.height).toSet(), {40});
    expect(picked.label, contains('`button`'));
  });

  test('the size the screens use most wins, whatever its name', () {
    final picked = ComponentSamples.select(ComponentKind.button, [
      for (var i = 0; i < 5; i++) _button('button', 'small', 40),
      for (var i = 0; i < 3; i++) _button('button', 'medium', 56),
    ]);
    expect(picked.samples.map((s) => s.height).toSet(), {40});
    expect(picked.label, contains('small'));
  });

  test('side sheets are not bottom sheets', () {
    expect(ComponentKind.match('side sheet type=modal'), isNull);
    expect(ComponentKind.match('bottom sheet'), ComponentKind.bottomSheet);
    expect(ComponentKind.match('sheet'), ComponentKind.bottomSheet);
    expect(
      ComponentKind.match('Modal breakpoint=mobile'),
      ComponentKind.dialog,
    );
  });

  test('three definitions in the set beat resized instances', () {
    final resized = [for (var i = 0; i < 9; i++) _button('button', 'm', 48)];
    final defined = [
      for (var i = 0; i < 3; i++) _button('button', 'm', 40, definition: true),
    ];
    final picked = ComponentSamples.select(ComponentKind.button, [
      ...resized,
      ...defined,
    ]);
    expect(picked.samples.map((s) => s.height).toSet(), {40});
    final one = ComponentSamples.select(ComponentKind.button, [
      ...resized,
      defined.first,
    ]);
    expect(one.samples.map((s) => s.height).toSet(), {48, 40});
  });
}
