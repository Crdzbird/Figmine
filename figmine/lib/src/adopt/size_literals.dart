import 'package:figmine/src/adopt/literal.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/literal_scanner.dart';

/// Finds hard coded spacings and radii.
abstract final class SizeLiterals {
  static final RegExp _insets = RegExp(
    r'EdgeInsets(?:Directional)?\.(?:all|only|symmetric|fromLTRB|fromSTEB)'
    r'\(([^()]*)\)',
  );

  static final RegExp _box = RegExp(r'SizedBox\(');

  static final RegExp _radius = RegExp(
    r'(?:BorderRadius|Radius)\.circular\(\s*(\d+(?:\.\d+)?)\s*\)',
  );

  static final RegExp _number = RegExp(r'(?<![\w.])(\d+(?:\.\d+)?)(?![\w.])');

  static final RegExp _sized = RegExp(r'\b(width|height)\s*:\s*$');

  static final RegExp _digit = RegExp('[0-9]');

  /// Numbers in `EdgeInsets` and `SizedBox` widths and heights, and
  /// circular radii, in [code].
  static List<Literal> find(String code, LiteralAt at) {
    final found = <Literal>[];
    void numbers(RegExpMatch m) {
      final args = m.group(1)!;
      final start = m.end - 1 - args.length;
      for (final n in _number.allMatches(args)) {
        found.add(
          at(
            start + n.start,
            n.end - n.start,
            LiteralKind.spacing,
            num.parse(n.group(1)!),
          ),
        );
      }
    }

    _insets.allMatches(code).forEach(numbers);
    for (final m in _box.allMatches(code)) {
      var depth = 0;
      for (var i = m.end; i < code.length && depth >= 0; i++) {
        final char = code[i];
        depth += char == '(' ? 1 : (char == ')' ? -1 : 0);
        if (depth != 0 || !_digit.hasMatch(char)) continue;
        final n = _number.matchAsPrefix(code, i);
        if (n == null || !_sized.hasMatch(code.substring(m.end, i))) continue;
        found.add(
          at(i, n.end - i, LiteralKind.spacing, num.parse(n.group(1)!)),
        );
        i = n.end - 1;
      }
    }
    for (final m in _radius.allMatches(code)) {
      final value = m.group(1)!;
      final start = m.end - m.group(0)!.length + m.group(0)!.lastIndexOf(value);
      found.add(at(start, value.length, LiteralKind.radius, num.parse(value)));
    }
    return found;
  }
}
