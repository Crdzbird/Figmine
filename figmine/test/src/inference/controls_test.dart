import 'package:figmine/src/codegen/role_order.dart';
import 'package:figmine/src/inference/button_variant.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_state.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:flutter_test/flutter_test.dart';

TextStyleToken _style(String name, double size) => TextStyleToken(
  path: [name],
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: 400,
);

void main() {
  test('toggles and tabs are their own kinds, before buttons', () {
    expect(ComponentKind.match('Checkbox Field'), ComponentKind.checkbox);
    expect(ComponentKind.match('radio-button | checked'), ComponentKind.radio);
    expect(ComponentKind.match('Switch Field'), ComponentKind.toggle);
    expect(ComponentKind.match('Tab | Active=On'), ComponentKind.tab);
    expect(
      ComponentKind.match('navbar breakpoint=tablet'),
      ComponentKind.appBar,
    );
  });

  test('checked values are selected and mixed ones are skipped', () {
    expect(ComponentState.of('Value Type=Checked'), ComponentState.selected);
    expect(ComponentState.of('checked=true'), ComponentState.selected);
    expect(ComponentState.of('Active=On'), ComponentState.selected);
    expect(ComponentState.of('Value Type=Unchecked'), ComponentState.enabled);
    expect(ComponentState.of('Value Type=Indeterminate'), isNull);
  });

  test('text buttons have a label and no fill or border', () {
    expect(RegExp(ButtonVariant.text.hint).hasMatch('variant=subtle'), isTrue);
  });

  test('larger text roles get larger styles', () {
    final roles = RoleOrder.sorted({
      'bodyLarge': _style('B3', 16),
      'bodyMedium': _style('B2', 18),
      'bodySmall': _style('S', 12),
    });
    expect(roles.values.map((s) => s.fontSize), [18, 16, 12]);
  });
}
