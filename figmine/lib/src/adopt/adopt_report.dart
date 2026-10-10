import 'package:figmine/src/adopt/adopt_project.dart';
import 'package:figmine/src/adopt/suggestion.dart';

/// Describes hard coded values and their tokens for the terminal.
abstract final class AdoptReport {
  /// One line per value, then a summary.
  static List<String> lines(List<AdoptFile> files) {
    final all = [for (final f in files) ...f.found];
    if (all.isEmpty) return ['No hard coded design values match a token.'];
    final fixable = all.where((s) => s.constant != null).length;
    final summary =
        '${count(all.length, 'hard coded value')} in '
        '${count(files.length, 'file')}; $fixable can be replaced with '
        '--apply.';
    return [for (final s in all) _line(s), summary];
  }

  static String _line(Suggestion s) {
    final l = s.literal;
    return '${l.path}:${l.line}:${l.column} ${l.text}: ${advice(s)}';
  }

  /// [n] followed by [noun], plural unless [n] is one.
  static String count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

  /// What to use instead of the value of [s].
  static String advice(Suggestion s) {
    final more = s.others.length > 3 ? ' and ${s.others.length - 3} more' : '';
    final matches = 'matches ${s.others.take(3).join(', ')}$more';
    final parts = [
      if (s.constant case final c?) 'use $c',
      if (s.constant == null && s.others.isNotEmpty) matches,
      if (s.themed case final t?) 'in widgets $t',
      if (s.constant == null && s.others.isEmpty && s.themed == null)
        'no token has this value',
    ];
    return parts.join('; ');
  }
}
