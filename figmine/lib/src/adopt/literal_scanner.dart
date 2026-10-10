import 'package:figmine/src/adopt/color_literals.dart';
import 'package:figmine/src/adopt/literal.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/size_literals.dart';

/// Builds a literal from its offset and length in the scanned source.
typedef LiteralAt = Literal Function(
  int offset,
  int length,
  LiteralKind kind,
  num value,
);

/// Finds hard coded colors, spacings and radii in Dart source.
abstract final class LiteralScanner {
  /// Every literal in [source], the contents of the file at [path], in
  /// order. Line comments are skipped.
  static List<Literal> scan(String source, String path) {
    final code = source.replaceAllMapped(
      RegExp('//[^\n]*'),
      (m) => ' ' * m.group(0)!.length,
    );
    Literal at(int offset, int length, LiteralKind kind, num value) {
      final before = source.substring(0, offset);
      final context = code.substring(0, offset);
      return (
        path: path,
        offset: offset,
        length: length,
        line: '\n'.allMatches(before).length + 1,
        column: offset - before.lastIndexOf('\n'),
        kind: kind,
        text: source.substring(offset, offset + length),
        value: value,
        owner: _owner(context),
        property: _property.firstMatch(context)?.group(1),
      );
    }

    return [...ColorLiterals.find(code, at), ...SizeLiterals.find(code, at)]
      ..sort((a, b) => a.offset - b.offset);
  }

  static final RegExp _property = RegExp(r'(\w+)\s*:\s*(?:const\s+)?$');

  static final RegExp _call = RegExp(r'([\w.]+)\s*$');

  /// The constructor or function whose open argument list ends [code].
  static String? _owner(String code) {
    var depth = 0;
    for (var i = code.length - 1; i >= 0; i--) {
      final char = code[i];
      if (char == ')') depth++;
      if (char != '(') continue;
      if (depth > 0) {
        depth--;
        continue;
      }
      return _call.firstMatch(code.substring(0, i))?.group(1);
    }
    return null;
  }
}
