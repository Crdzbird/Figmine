import 'package:figmine/src/audit/contrast_audit.dart';
import 'package:figmine/src/audit/contrast_fixer.dart';
import 'package:figmine/src/audit/fix_snippet.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/inference/color_math.dart';
import 'package:figmine/src/lock/accessibility_section.dart';
import 'package:flutter_test/flutter_test.dart';

SchemeField _field(String name, int light, int dark) => (
  name: name,
  doc: '',
  light: (code: '', file: null),
  dark: (code: '', file: null),
  lightArgb: light,
  darkArgb: dark,
);

void main() {
  final fields = [
    _field('surface', 0xFFFFFFFF, 0xFF1E1E1E),
    _field('onSurface', 0xFF1E1E1E, 0xFFFFFFFF),
    _field('outline', 0xFF9D9D9D, 0xFF8A8A8A),
    _field('success', 0xFF4CAF50, 0xFF4CAF50),
    _field('onSuccess', 0xFFFFFFFF, 0xFFFFFFFF),
  ];
  const tokens = [
    (
      collection: 'Color',
      name: 'Text/Brand',
      light: 0xFF3567F6,
      dark: 0xFF3567F6,
    ),
    (
      collection: 'Color',
      name: 'Gray/500',
      light: 0xFF757575,
      dark: 0xFF757575,
    ),
    (
      collection: 'Color',
      name: 'Border/Strong',
      light: 0xFF8F8F8F,
      dark: 0xFF8F8F8F,
    ),
  ];
  final findings = ContrastAudit.run(fields);
  final fixes = ContrastFixer.suggest(findings, fields, tokens);

  test('the closest token for the same use that passes is suggested', () {
    final outline = findings.indexWhere((f) => f.foreground == 'outline');
    expect(fixes[outline]!.token, 'Border/Strong');
    expect(fixes[outline]!.ratio, greaterThanOrEqualTo(3));
    expect(fixes[outline]!.bothModes, isTrue);
  });

  test('without a passing token the color moves in tone, keeping its hue', () {
    final onSuccess = findings.indexWhere((f) => f.foreground == 'onSuccess');
    final fix = fixes[onSuccess]!;
    expect(fix.token, isNull);
    expect(ColorMath.contrast(fix.argb, 0xFF4CAF50), greaterThanOrEqualTo(4.5));
  });

  test('fixes become roles or overrides in figmine.yaml and the report', () {
    final yaml = FixSnippet.yaml(findings, fixes, fields);
    expect(yaml, contains('  roles:\n    outline: "Border/Strong"'));
    expect(yaml, contains('    onSuccess: {light: "#'));
    final buffer = StringBuffer();
    AccessibilitySection.write(buffer, (
      findings: findings,
      checked: 10,
      fixes: fixes,
      snippet: yaml,
    ));
    expect(buffer.toString(), contains('`Border/Strong` #8F8F8F'));
    expect(buffer.toString(), contains('```yaml'));
  });
}
