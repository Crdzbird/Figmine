import 'package:figmine/src/adopt/suggestion.dart';

/// Replaces literals with their const tokens in one source file.
abstract final class AdoptRewriter {
  static final RegExp _const = RegExp(r'const\s+$');

  static final RegExp _import = RegExp(
    r"^import '([^']+)';[ \t]*$",
    multiLine: true,
  );

  static final RegExp _directive = RegExp(
    r'^(import|export|library|part)\b[^;]*;[ \t]*$',
    multiLine: true,
  );

  /// [source] with every suggestion that has a constant applied, and an
  /// import of [barrel] added in sorted order when the file lacks it. A
  /// `const` written right before a replaced color goes with it, since the
  /// token is a constant itself.
  static String apply(
    String source,
    List<Suggestion> suggestions,
    String barrel,
  ) {
    final edits = [
      for (final s in suggestions)
        if (s.constant != null) s,
    ]..sort((a, b) => b.literal.offset - a.literal.offset);
    if (edits.isEmpty) return source;
    var result = source;
    for (final edit in edits) {
      final literal = edit.literal;
      final before = result.substring(0, literal.offset);
      final keyword = _const.firstMatch(before);
      final start = keyword == null ? literal.offset : keyword.start;
      result = result.replaceRange(
        start,
        literal.offset + literal.length,
        edit.constant!,
      );
    }
    final import = "import '$barrel';";
    if (result.contains(import)) return result;
    final imports = _import.allMatches(result).toList();
    final after = imports
        .where((m) => m.group(1)!.compareTo(barrel) > 0)
        .firstOrNull;
    if (after != null) {
      return result.replaceRange(after.start, after.start, '$import\n');
    }
    final last = imports.lastOrNull ?? _directive.allMatches(result).lastOrNull;
    if (last == null) return '$import\n\n$result';
    return result.replaceRange(last.end, last.end, '\n$import');
  }
}
