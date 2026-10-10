import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/tokens/color_value.dart';

/// Parses DTCG values into figmine values.
abstract final class DtcgValues {
  static const Map<String, int> _weights = {
    'thin': 100,
    'hairline': 100,
    'extralight': 200,
    'ultralight': 200,
    'light': 300,
    'normal': 400,
    'regular': 400,
    'book': 400,
    'medium': 500,
    'semibold': 600,
    'demibold': 600,
    'bold': 700,
    'extrabold': 800,
    'ultrabold': 800,
    'black': 900,
    'heavy': 900,
  };

  /// A color from `#RGB`, `#RRGGBB`, `#RRGGBBAA` or an sRGB object.
  static ColorValue? color(Object? raw) {
    if (raw is String) return _hex(raw);
    final map = Json.map(raw);
    final components = Json.list(map['components']).whereType<num>().toList();
    final alpha = map['alpha'];
    if (components.length == 3) {
      return ColorValue(
        r: components[0].toDouble(),
        g: components[1].toDouble(),
        b: components[2].toDouble(),
        a: alpha is num ? alpha.toDouble() : 1,
      );
    }
    final hex = map['hex'];
    return hex is String ? _hex(hex) : null;
  }

  /// A number from a number, a `{value, unit}` dimension or `"16px"`.
  /// Rem values are converted with 16 pixels per rem.
  static double? number(Object? raw) {
    if (raw is num) return raw.toDouble();
    final map = Json.map(raw);
    final value = map['value'];
    if (value is num) return value * (map['unit'] == 'rem' ? 16 : 1).toDouble();
    if (raw is! String) return null;
    final match = RegExp(r'^(-?[\d.]+)(px|rem)?$').firstMatch(raw.trim());
    final parsed = double.tryParse(match?.group(1) ?? '');
    if (parsed == null) return null;
    return match!.group(2) == 'rem' ? parsed * 16 : parsed;
  }

  /// A font weight from a number or a name such as `semi-bold`.
  static int? weight(Object? raw) {
    if (raw is num) return raw.round();
    if (raw is! String) return null;
    return _weights[raw.toLowerCase().replaceAll(RegExp('[^a-z]'), '')];
  }

  /// A string, or the first family of a font family list.
  static String? string(Object? raw) {
    if (raw is String) return raw;
    final list = Json.list(raw);
    return list.isNotEmpty && list.first is String
        ? list.first! as String
        : null;
  }

  static ColorValue? _hex(String raw) {
    var hex = raw.trim().replaceFirst('#', '');
    if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
    if (hex.length == 6) hex = '${hex}ff';
    final value = int.tryParse(hex, radix: 16);
    if (hex.length != 8 || value == null) return null;
    return ColorValue.fromArgb((value & 0xFF) << 24 | value >> 8);
  }
}
