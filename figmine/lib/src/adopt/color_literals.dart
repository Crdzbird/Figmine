import 'package:figmine/src/adopt/literal.dart';
import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/literal_scanner.dart';

/// Finds hard coded colors.
abstract final class ColorLiterals {
  static final RegExp _hex = RegExp(r'Color\(\s*0x([0-9A-Fa-f]{8})\s*\)');

  static final RegExp _channels = RegExp(
    r'Color\.from(ARGB|RGBO)\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,'
    r'\s*([\d.]+)\s*\)',
  );

  /// `Color(0xAARRGGBB)`, `Color.fromARGB` and `Color.fromRGBO` in [code].
  static List<Literal> find(String code, LiteralAt at) => [
    for (final m in _hex.allMatches(code))
      at(
        m.start,
        m.end - m.start,
        LiteralKind.color,
        int.parse(m.group(1)!, radix: 16),
      ),
    for (final m in _channels.allMatches(code))
      at(m.start, m.end - m.start, LiteralKind.color, _argb(m)),
  ];

  static int _argb(RegExpMatch m) {
    final c = [for (var i = 2; i <= 5; i++) num.parse(m.group(i)!)];
    final rgbo = m.group(1) == 'RGBO';
    final alpha = rgbo ? (c[3] * 255).round() : c[0].toInt();
    final rgb = rgbo ? c.sublist(0, 3) : c.sublist(1);
    return alpha << 24 |
        rgb[0].toInt() << 16 |
        rgb[1].toInt() << 8 |
        rgb[2].toInt();
  }
}
