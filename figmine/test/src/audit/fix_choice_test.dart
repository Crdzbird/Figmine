import 'package:figmine/src/audit/contrast_audit.dart';
import 'package:figmine/src/audit/contrast_fixer.dart';
import 'package:figmine/src/codegen/scheme/scheme_fields.dart';
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
    _field('outline', 0xFFD9D9D9, 0xFF444444),
  ];
  final findings = ContrastAudit.run(fields);

  test('a role failing in both modes gets one token that fixes both', () {
    final fixes = ContrastFixer.suggest(findings, fields, const [
      (
        collection: 'C',
        name: 'Border/Light',
        light: 0xFF8A8A8A,
        dark: 0xFF3A3A3A,
      ),
      (
        collection: 'C',
        name: 'Border/Strong',
        light: 0xFF757575,
        dark: 0xFF8A8A8A,
      ),
    ]);
    expect(findings.map((f) => f.mode), ['light', 'dark']);
    expect(fixes.map((f) => f!.token).toSet(), {'Border/Strong'});
    expect(fixes.every((f) => f!.bothModes), isTrue);
  });

  test('tokens for a state, such as disabled, rank behind plain ones', () {
    final fixes = ContrastFixer.suggest(findings, fields, const [
      (
        collection: 'C',
        name: 'Border/Disabled',
        light: 0xFF8F8F8F,
        dark: 0xFF8F8F8F,
      ),
      (
        collection: 'C',
        name: 'Border/Regular',
        light: 0xFF7A7A7A,
        dark: 0xFF8F8F8F,
      ),
    ]);
    expect(fixes.first!.token, 'Border/Regular');
  });
}
