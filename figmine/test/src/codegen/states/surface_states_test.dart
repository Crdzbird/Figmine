import 'package:figmine/src/audit/contrast_audit.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/states/state_fallback.dart';
import 'package:figmine/src/codegen/states/state_field_specs.dart';
import 'package:figmine/src/codegen/states/state_readable.dart';
import 'package:figmine/src/inference/color/color_math.dart';
import 'package:flutter_test/flutter_test.dart';

SchemeField _field(String name, int light, int dark, [String doc = '']) => (
  name: name,
  doc: doc,
  light: StateFallback.literal(light),
  dark: StateFallback.literal(dark),
  lightArgb: light,
  darkArgb: dark,
);

void main() {
  final label = StateFieldSpecs.all.firstWhere((s) => s.name == 'onTooltip');

  test('a label that disappears on the dark fill moves to a readable tone', () {
    final rest = _field('tooltip', 0xFFFFFFFF, 0xFF1E1E1E);
    final black = _field('onTooltip', 0xFF000000, 0xFF000000);
    expect(StateReadable.keeps(label, black, 0xFF000000, rest), isFalse);
    final fixed = StateReadable.fix(label, black, 0xFF000000, rest)!;
    expect(ColorMath.contrast(fixed, 0xFF1E1E1E), greaterThanOrEqualTo(4.5));
    expect(StateReadable.fix(label, black, 0xFFFFFFFF, rest), 0xFFFFFFFF);
  });

  test('pairs of two Material defaults are not audited', () {
    final findings = ContrastAudit.run([
      _field('navigationBar', 0xFFE0E0E0, 0xFF202020, 'Material default: x.'),
      _field('onNavigationBar', 0xFF9E9E9E, 0xFF505050, 'Material default: y.'),
      _field('snackbar', 0xFFE0E0E0, 0xFF202020, 'The variant in Figma.'),
      _field('onSnackbar', 0xFF9E9E9E, 0xFF505050, 'Material default: y.'),
    ]);
    expect(findings.map((f) => f.foreground).toSet(), {'onSnackbar'});
  });

  test('a transparent fill is no backdrop for readability', () {
    final outline = StateFieldSpecs.all.firstWhere(
      (s) => s.name == 'outlinedButtonOutline',
    );
    final rest = _field('outlinedButton', 0x00000000, 0x00000000);
    final variant = _field('outlineVariant', 0xFFCAC4D0, 0xFF49454F);
    expect(StateReadable.need(outline, variant, rest), isNull);
    expect(StateReadable.keeps(outline, variant, 0xFF49454F, rest), isTrue);
  });
}
