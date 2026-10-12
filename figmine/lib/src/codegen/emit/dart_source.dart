import 'package:figmine/src/codegen/collections/effect_source.dart';
import 'package:figmine/src/codegen/collections/motion_source.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/curve_value.dart';
import 'package:figmine/src/tokens/duration_value.dart';
import 'package:figmine/src/tokens/font_weight_value.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';

/// Small helpers that build Dart source text.
abstract final class DartSource {
  /// Formats `name(...)` with one argument per line.
  static String call(String name, Iterable<String> args) {
    final list = args.toList();
    if (list.isEmpty) return '$name()';
    return '$name(\n${list.map((arg) => '  $arg,\n').join()})';
  }

  /// Formats a named parameter list, or `()` when [params] is empty.
  static String params(Iterable<String> params) {
    final list = params.toList();
    if (list.isEmpty) return '()';
    return '({\n${list.map((param) => '  $param,\n').join()}})';
  }

  /// Formats a `Color` literal.
  static String color(String hex) => 'Color($hex)';

  /// Formats a color, number or string token value.
  static String value(Object value) => switch (value) {
    final ColorValue color => DartSource.color(color.hex),
    final double numeric => number(numeric),
    final String text => string(text),
    final ShadowValue shadow => EffectSource.shadows(shadow),
    final GradientValue gradient => EffectSource.gradient(gradient),
    final bool flag => '$flag',
    final DurationValue d => MotionSource.duration(d),
    final CurveValue c => MotionSource.curve(c),
    final FontWeightValue w => MotionSource.weight(w),
    _ => throw ArgumentError.value(value, 'value', 'Unsupported token value'),
  };

  /// Formats a number, using an int literal for whole values.
  static String number(double value) {
    if (value == value.roundToDouble()) return '${value.round()}';
    return '$value';
  }

  /// Escapes [value] as a string literal, split into adjacent literals so
  /// lines stay short.
  static String string(String value) {
    final chunks = <String>[];
    var rest = value;
    while (rest.length > 56) {
      final cut = rest.lastIndexOf(' ', 56);
      final end = cut > 0 ? cut + 1 : 56;
      chunks.add(rest.substring(0, end));
      rest = rest.substring(end);
    }
    chunks.add(rest);
    return chunks.map(_literal).join(' ');
  }

  static String _literal(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .replaceAll(r'$', r'\$')
        .replaceAll('\n', r'\n');
    return "'$escaped'";
  }

  /// Escapes [value] for use inside a doc comment code span.
  static String docCode(String value) => '`${value.replaceAll('`', "'")}`';
}
