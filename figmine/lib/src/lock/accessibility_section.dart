import 'package:figmine/src/audit/audit_result.dart';
import 'package:figmine/src/audit/contrast_fix.dart';
import 'package:figmine/src/inference/color_math.dart';

/// Renders the contrast audit as Markdown.
abstract final class AccessibilitySection {
  /// Writes the section into [buffer]. Nothing when the audit did not run.
  static void write(StringBuffer buffer, AuditResult? audit) {
    if (audit == null) return;
    final findings = audit.findings;
    buffer
      ..writeln('### Accessibility')
      ..writeln();
    if (findings.isEmpty) {
      buffer
        ..writeln(
          'All ${audit.checked} color pairs meet WCAG AA contrast in light '
          'and dark mode.',
        )
        ..writeln();
      return;
    }
    buffer
      ..writeln('${findings.length} color pairs are below WCAG AA contrast:')
      ..writeln()
      ..writeln('| Text or outline | On | Mode | Contrast | Needs | Fix |')
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (var i = 0; i < findings.length; i++) {
      final f = findings[i];
      final fg = '`${f.foreground}` ${ColorMath.hex(f.foregroundArgb)}';
      final bg = '`${f.background}` ${ColorMath.hex(f.backgroundArgb)}';
      final fix = i < audit.fixes.length ? audit.fixes[i] : null;
      buffer.writeln(
        '| $fg | $bg | ${f.mode} | ${f.ratio.toStringAsFixed(2)}:1 | '
        '${f.required.toStringAsFixed(1)}:1 | ${describe(fix)} |',
      );
    }
    buffer.writeln();
    if (audit.snippet.isEmpty) return;
    buffer
      ..writeln('To apply the fixes, add to `figmine.yaml`:')
      ..writeln()
      ..writeln('```yaml')
      ..writeln(audit.snippet)
      ..writeln('```')
      ..writeln();
  }

  /// One terminal line per failing pair with its fix.
  static List<String> log(AuditResult audit) => [
    for (var i = 0; i < audit.findings.length; i++) _line(audit, i),
  ];

  static String _line(AuditResult audit, int i) {
    final f = audit.findings[i];
    final fix = i < audit.fixes.length ? audit.fixes[i] : null;
    final ratio = f.ratio.toStringAsFixed(2);
    final needs = f.required.toStringAsFixed(1);
    return 'Contrast: ${f.foreground} on ${f.background} in ${f.mode} is '
        '$ratio:1, needs $needs:1. Fix: ${describe(fix)}.';
  }

  /// The fix as table text: the token or the moved color, and its ratio.
  static String describe(ContrastFix? fix) {
    if (fix == null) return 'none found';
    final ratio = '${fix.ratio.toStringAsFixed(2)}:1';
    final hex = ColorMath.hex(fix.argb);
    final token = fix.token;
    if (token == null) return '$hex, $ratio, same hue';
    final modes = fix.bothModes ? ', both modes' : '';
    return '`$token` $hex, $ratio$modes';
  }
}
