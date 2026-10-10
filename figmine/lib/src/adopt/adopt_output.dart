import 'package:figmine/src/adopt/adopt_project.dart';
import 'package:figmine/src/adopt/adopt_report.dart';
import 'package:figmine/src/adopt/suggestion.dart';

/// Writes adopt results for GitHub: annotations and a Markdown section.
abstract final class AdoptOutput {
  static const int _rows = 30;

  /// One GitHub Actions warning per value, shown on the changed lines.
  static List<String> annotations(List<AdoptFile> files) => [
    for (final file in files) ...file.found.map(_annotation),
  ];

  static String _annotation(Suggestion s) {
    final l = s.literal;
    final where = 'file=${l.path},line=${l.line},col=${l.column}';
    return '::warning $where,title=figmine adopt::${AdoptReport.advice(s)}';
  }

  /// A Markdown section for a pull request body.
  static String markdown(List<AdoptFile> files) {
    final all = [for (final f in files) ...f.found];
    if (all.isEmpty) return '';
    final fixable = all.where((s) => s.constant != null).length;
    final summary =
        '${AdoptReport.count(all.length, 'hard coded value')} in the app; '
        '$fixable can be replaced with `figmine adopt --apply`.';
    return [
      '',
      '### Hard coded values',
      '',
      summary,
      '',
      '| Where | Value | Advice |',
      '| --- | --- | --- |',
      for (final s in all.take(_rows)) _row(s),
      if (all.length > _rows) '\nAnd ${all.length - _rows} more.',
      '',
    ].join('\n');
  }

  static String _row(Suggestion s) {
    final l = s.literal;
    final value = l.text.replaceAll('|', r'\|');
    return '| `${l.path}:${l.line}` | `$value` | ${AdoptReport.advice(s)} |';
  }
}
