import 'package:figmine/src/score/theme_snapshot.dart';

/// Reads the text roles of a generated typography library.
abstract final class TextValues {
  static final RegExp _style = RegExp(
    r'static const TextStyle (\w+) = TextStyle\(([^;]*?)\);',
  );

  static final RegExp _family = RegExp(r"fontFamily:\s*'([^']*)'");

  static final RegExp _size = RegExp(r'fontSize:\s*([\d.]+)');

  static final RegExp _role = RegExp(
    r'^\s+(\w+):\s*(\w+),\s*$',
    multiLine: true,
  );

  /// The family and size of each TextTheme role in [source].
  static Map<String, TextFacts> read(String source) {
    final styles = <String, TextFacts>{
      for (final m in _style.allMatches(source))
        if (_family.firstMatch(m.group(2)!)?.group(1) case final family?)
          if (_size.firstMatch(m.group(2)!)?.group(1) case final size?)
            m.group(1)!: (family: family, size: double.parse(size)),
    };
    final start = source.indexOf('TextTheme textTheme = TextTheme(');
    if (start < 0) return const {};
    final block = source.substring(start, source.indexOf(');', start));
    return {
      for (final m in _role.allMatches(block)) m.group(1)!: ?styles[m.group(2)],
    };
  }
}
