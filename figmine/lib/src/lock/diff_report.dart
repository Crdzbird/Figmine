import 'package:figmine/src/audit/audit_result.dart';
import 'package:figmine/src/figma/figma_version.dart';
import 'package:figmine/src/lock/accessibility_section.dart';
import 'package:figmine/src/lock/font_section.dart';
import 'package:figmine/src/lock/impact_section.dart';
import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/report_table.dart';
import 'package:figmine/src/lock/token_diff.dart';
import 'package:figmine/src/lock/versions_section.dart';
import 'package:figmine/src/migrate/migrations.dart';

/// Renders a [TokenDiff] as Markdown for pull request descriptions.
abstract final class DiffReport {
  /// Returns the report comparing [previous] with [next].
  static String markdown({
    required String fileName,
    required LockFile? previous,
    required LockFile next,
    required TokenDiff diff,
    List<FigmaVersion> versions = const [],
    AuditResult? audit,
    MigrationPlan migration = Migrations.none,
    List<MissingFont> fonts = const [],
  }) {
    final link = 'https://www.figma.com/design/${next.fileKey}';
    final buffer = StringBuffer()
      ..writeln('## Figma design tokens update')
      ..writeln()
      ..writeln('Source: [$fileName]($link)')
      ..writeln()
      ..writeln('| | Version | Last modified |')
      ..writeln('| --- | --- | --- |')
      ..writeln(
        '| Before | ${previous?.version ?? '-'} | '
        '${previous?.lastModified ?? '-'} |',
      )
      ..writeln('| After | ${next.version} | ${next.lastModified} |')
      ..writeln();
    VersionsSection.write(buffer, versions);
    ReportTable.write(
      buffer,
      'Tokens',
      diff.tokens,
      previous?.tokens,
      next.tokens,
    );
    ReportTable.write(
      buffer,
      'Typography',
      diff.typography,
      previous?.typography,
      next.typography,
    );
    ReportTable.write(
      buffer,
      'Components',
      diff.components,
      previous?.components,
      next.components,
    );
    _icons(buffer, diff.icons);
    ImpactSection.write(buffer, migration);
    AccessibilitySection.write(buffer, audit);
    FontSection.write(buffer, fonts);
    if (diff.isEmpty) buffer.writeln('No token changes.');
    return _fit(buffer.toString());
  }

  static const int _maxLength = 60000;

  /// Cuts the report to stay below GitHub's pull request body limit.
  static String _fit(String report) {
    if (report.length <= _maxLength) return report;
    final cut = report.lastIndexOf('\n', _maxLength);
    return '${report.substring(0, cut)}\n\n_The report was shortened. '
        'Every change is in figmine.lock.json._\n';
  }

  static void _icons(StringBuffer buffer, NameChanges changes) {
    final groups = {
      'Added': changes.added,
      'Changed': changes.changed,
      'Removed': changes.removed,
    };
    if (groups.values.every((names) => names.isEmpty)) return;
    buffer
      ..writeln('### Icons')
      ..writeln();
    for (final group in groups.entries) {
      if (group.value.isEmpty) continue;
      final names = group.value.map((n) => '`$n`').join(', ');
      buffer.writeln('- ${group.key} (${group.value.length}): $names');
    }
    buffer.writeln();
  }
}
