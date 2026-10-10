import 'package:figmine/src/score/score_item.dart';

/// Summarizes a scorecard for the terminal and for Markdown.
abstract final class ScoreReport {
  /// The total score of [items], from 0 to 100.
  static double total(List<ScoreItem> items) => _percent(items);

  /// Section scores, then every value that did not match, then the total.
  static List<String> lines(List<ScoreItem> items) => [
    for (final (section, part) in _sections(items)) _section(section, part),
    for (final i in items)
      if (i.grade != Grade.match) _miss(i),
    'Score: ${_fixed(total(items))}% of ${items.length} values.',
  ];

  /// A Markdown scorecard of [items] from [source].
  static String markdown(List<ScoreItem> items, String source) {
    final score = '**${_fixed(total(items))}%** of ${items.length} values';
    return [
      '## figmine scorecard',
      '',
      'Source: $source. Score: $score.',
      '',
      '| Section | Score |',
      '| --- | --- |',
      for (final (section, part) in _sections(items))
        '| $section | ${_percent(part).round()}% |',
      '',
      '| Value | Expected | Got | Grade |',
      '| --- | --- | --- | --- |',
      for (final i in items) _row(i),
      '',
    ].join('\n');
  }

  static String _section(String section, List<ScoreItem> part) {
    final points = part.fold<double>(0, (sum, i) => sum + i.grade.points);
    final shown = points == points.roundToDouble()
        ? '${points.round()}'
        : points.toStringAsFixed(1);
    final name = section.padRight(12);
    return '$name ${_percent(part).round()}% ($shown of ${part.length})';
  }

  static String _miss(ScoreItem i) {
    final grade = i.grade.name.padRight(8);
    return '$grade ${i.section}.${i.name}: expected ${i.expected}, '
        'got ${i.actual}';
  }

  static String _row(ScoreItem i) {
    final value = '${i.section}.${i.name}';
    return '| $value | `${i.expected}` | `${i.actual}` | ${i.grade.name} |';
  }

  static List<(String, List<ScoreItem>)> _sections(List<ScoreItem> items) {
    final by = <String, List<ScoreItem>>{};
    for (final i in items) {
      (by[i.section] ??= []).add(i);
    }
    return [for (final e in by.entries) (e.key, e.value)];
  }

  static String _fixed(double value) => value.toStringAsFixed(1);

  static double _percent(List<ScoreItem> items) => items.isEmpty
      ? 0
      : items.fold<double>(0, (sum, i) => sum + i.grade.points) /
            items.length *
            100;
}
