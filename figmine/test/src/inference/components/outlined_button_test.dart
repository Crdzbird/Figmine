import 'package:figmine/src/codegen/states/state_fallback.dart';
import 'package:figmine/src/codegen/states/state_field_specs.dart';
import 'package:figmine/src/inference/components/button_style_kind.dart';
import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:flutter_test/flutter_test.dart';

ComponentSample _button({int? fill, int? stroke, int? label = 0xFF3567F6}) => (
  kind: ComponentKind.button,
  name: 'button hierarchy=secondary',
  instance: true,
  definition: false,
  family: 'button',
  fill: fill,
  fillVariable: null,
  stroke: stroke,
  strokeVariable: null,
  label: label,
  labelVariable: null,
  radius: 8,
  pill: false,
  height: 40,
  paddingHorizontal: 16,
  padding: null,
  shadow: 0,
  mark: null,
  markVariable: null,
);

void main() {
  test('outlined buttons have a border apart from a light or no fill', () {
    expect(
      ButtonStyleKind.isOutlined(_button(fill: 0xFFFFFFFF, stroke: 0xFF3567F6)),
      isTrue,
    );
    expect(ButtonStyleKind.isOutlined(_button(stroke: 0xFF767676)), isTrue);
    expect(
      ButtonStyleKind.isOutlined(_button(fill: 0xFF2C2C2C, stroke: 0xFF2C2C2C)),
      isFalse,
    );
    expect(
      ButtonStyleKind.isOutlined(_button(fill: 0xFF3567F6, stroke: 0xFF1B115C)),
      isFalse,
    );
    expect(
      ButtonStyleKind.isOutlined(_button(label: null, stroke: 1)),
      isFalse,
    );
  });

  test('transparent defaults become state layers of the label color', () {
    final label = StateFallback.copy('onOutlinedButton', (
      name: 'primary',
      doc: '',
      light: StateFallback.literal(0xFF3567F6),
      dark: StateFallback.literal(0xFFC5D4FD),
      lightArgb: 0xFF3567F6,
      darkArgb: 0xFFC5D4FD,
    ), '');
    final hovered = StateFieldSpecs.all.firstWhere(
      (s) => s.name == 'outlinedButtonHovered',
    );
    final field = StateFallback.material(hovered, {'onOutlinedButton': label});
    expect(field.lightArgb, 0x143567F6);
    expect(field.darkArgb, 0x14C5D4FD);
  });
}
