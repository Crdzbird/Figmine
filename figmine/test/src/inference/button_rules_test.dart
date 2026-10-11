import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/content_inset.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentSample _button(
  String name, {
  String family = 'button',
  bool instance = true,
  double padding = 16,
}) => (
  kind: ComponentKind.button,
  name: name,
  instance: instance,
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
  height: 40,
  paddingHorizontal: padding,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('label inset adds the paddings of nested auto layout layers', () {
    final button = <String, Object?>{
      'type': 'INSTANCE',
      'layoutMode': 'HORIZONTAL',
      'paddingLeft': 2,
      'children': [
        {
          'type': 'FRAME',
          'layoutMode': 'HORIZONTAL',
          'paddingLeft': 14,
          'children': [
            {'type': 'INSTANCE', 'name': 'icon'},
            {'type': 'TEXT', 'name': 'Label'},
          ],
        },
      ],
    };
    expect(ContentInset.horizontal(button), 16);
    expect(
      ContentInset.horizontal({
        'type': 'FRAME',
        'children': [
          {'type': 'TEXT'},
        ],
      }),
      isNull,
    );
  });

  test('the most used button component in its resting state wins', () {
    final picked = ComponentSamples.select(ComponentKind.button, [
      for (var i = 0; i < 4; i++) _button('button | state=idle'),
      for (var i = 0; i < 3; i++) _button('button | state=hover', padding: 2),
      for (var i = 0; i < 3; i++)
        _button('legacy | size=medium', family: 'legacy', padding: 24),
      for (var i = 0; i < 5; i++)
        _button('tag', family: '', instance: false, padding: 11),
    ]);
    expect(picked.samples.map((s) => s.paddingHorizontal).toSet(), {16});
    expect(picked.label, 'resting `button` instances');
  });
}
