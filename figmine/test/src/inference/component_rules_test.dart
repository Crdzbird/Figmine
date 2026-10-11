import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/sample_reader.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentSample _sample(
  ComponentKind kind,
  String family, {
  String variant = '',
  double height = 40,
}) => (
  kind: kind,
  name: '$family $variant',
  instance: true,
  definition: false,
  family: family,
  fill: 1,
  fillVariable: null,
  stroke: null,
  strokeVariable: null,
  label: 1,
  labelVariable: null,
  radius: 8,
  pill: false,
  height: height,
  paddingHorizontal: 16,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

Map<String, Object?> _box(double w, double h, {bool paint = false}) => {
  'type': 'FRAME',
  'absoluteBoundingBox': {'x': 0, 'y': 0, 'width': w, 'height': h},
  if (paint)
    'fills': [
      {
        'type': 'SOLID',
        'color': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
      },
    ],
};

void main() {
  test('inputs are measured on their field box, not the label above', () {
    final input = {
      ..._box(300, 66),
      'type': 'INSTANCE',
      'children': [
        {..._box(16, 16, paint: true), 'type': 'VECTOR'},
        {..._box(300, 48, paint: true), 'cornerRadius': 12},
      ],
    };
    final sample = SampleReader.read(input, ComponentKind.input);
    expect(sample.height, 48);
    expect(sample.radius, 12);
  });

  test('parts are skipped and names that say the kind come first', () {
    final picked = ComponentSamples.select(ComponentKind.chip, [
      for (var i = 0; i < 9; i++)
        _sample(ComponentKind.chip, 'value-tag', height: 25),
      for (var i = 0; i < 9; i++)
        _sample(ComponentKind.chip, 'chip-item', height: 20),
      for (var i = 0; i < 3; i++) _sample(ComponentKind.chip, 'filter chip'),
    ]);
    expect(picked.samples.map((s) => s.family).toSet(), {'filter chip'});
  });

  test('a single mobile variant wins over desktop ones', () {
    final picked = ComponentSamples.select(ComponentKind.appBar, [
      for (var i = 0; i < 5; i++)
        _sample(
          ComponentKind.appBar,
          'navbar',
          variant: 'breakpoint=desktop',
          height: 80,
        ),
      _sample(
        ComponentKind.appBar,
        'navbar',
        variant: 'breakpoint=mobile',
        height: 64,
      ),
    ]);
    expect(picked.samples.single.height, 64);
    expect(picked.label, 'resting mobile `navbar` instances');
  });
}
