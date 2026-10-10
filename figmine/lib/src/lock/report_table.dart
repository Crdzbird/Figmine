import 'package:figmine/src/lock/token_diff.dart';

/// Renders one change table of the report.
abstract final class ReportTable {
  static const int _maxRows = 100;

  /// Writes a table of [changes] titled [title], or nothing without
  /// changes. Changes come first; long tables count the rows they hide.
  static void write(
    StringBuffer buffer,
    String title,
    NameChanges changes,
    Map<String, String>? before,
    Map<String, String> after,
  ) {
    String cell(Map<String, String>? values, String name) =>
        values?[name] ?? '-';
    final rows = [
      for (final n in changes.changed)
        '| `$n` | changed | ${cell(before, n)} | ${cell(after, n)} |',
      for (final n in changes.removed)
        '| `$n` | removed | ${cell(before, n)} | - |',
      for (final n in changes.added) '| `$n` | added | - | ${cell(after, n)} |',
    ];
    if (rows.isEmpty) return;
    final hidden = rows.length - _maxRows;
    buffer
      ..writeln('### $title (${rows.length})')
      ..writeln()
      ..writeln('| Name | Change | Before | After |')
      ..writeln('| --- | --- | --- | --- |')
      ..writeAll(rows.take(_maxRows), '\n')
      ..writeln();
    if (hidden > 0) {
      buffer.writeln('| and $hidden more | | | |');
    }
    buffer.writeln();
  }
}
