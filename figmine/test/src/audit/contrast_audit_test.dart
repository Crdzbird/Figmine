import 'package:figmine/src/audit/contrast_audit.dart';
import 'package:figmine/src/codegen/scheme/scheme_fields.dart';
import 'package:figmine/src/lock/accessibility_section.dart';
import 'package:flutter_test/flutter_test.dart';

SchemeField _field(String name, int light, [int? dark]) => (
  name: name,
  doc: '',
  light: (code: '', file: null),
  dark: (code: '', file: null),
  lightArgb: light,
  darkArgb: dark ?? light,
);

void main() {
  final fields = [
    _field('primary', 0xFF3567F6, 0xFFB6C4FF),
    _field('onPrimary', 0xFFFFFFFF, 0xFF1D2D61),
    _field('surface', 0xFFFFFFFF, 0xFF121212),
    _field('onSurface', 0xFF1B115C, 0xFFF2F2F2),
    _field('outline', 0xFFE0E0E0, 0xFF8A8A8A),
    _field('success', 0xFF4CAF50),
    _field('onSuccess', 0xFFFFFFFF),
  ];

  test('pairs every onX with X, plus the Material pairs', () {
    final pairs = ContrastAudit.pairs(fields).map((p) => '${p.$1}/${p.$2}');
    expect(pairs, containsAll(['onPrimary/primary', 'onSuccess/success']));
    expect(pairs, contains('outline/surface'));
  });

  test('reports pairs below WCAG AA per mode', () {
    final findings = ContrastAudit.run(fields);
    final failing = {for (final f in findings) '${f.foreground}/${f.mode}'};
    expect(failing, {'onSuccess/light', 'onSuccess/dark', 'outline/light'});
    final outline = findings.firstWhere((f) => f.foreground == 'outline');
    expect(outline.required, 3);
    expect(outline.ratio, lessThan(1.5));
    final buffer = StringBuffer();
    AccessibilitySection.write(buffer, (
      findings: findings,
      checked: 10,
      fixes: const [],
      snippet: '',
    ));
    expect(
      buffer.toString(),
      contains('| `onSuccess` #FFFFFF | `success` #4CAF50 | light |'),
    );
  });

  test('says so when every pair passes', () {
    final buffer = StringBuffer();
    AccessibilitySection.write(buffer, (
      findings: const [],
      checked: 12,
      fixes: const [],
      snippet: '',
    ));
    expect(buffer.toString(), contains('All 12 color pairs meet WCAG AA'));
  });
}
