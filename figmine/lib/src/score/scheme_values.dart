import 'package:figmine/src/lock/lock_symbol.dart';

/// Reads the colors of a generated color scheme.
abstract final class SchemeValues {
  static final RegExp _field = RegExp(
    r'^\s+(\w+):\s*(Color\(0x([0-9A-Fa-f]{8})\)|(\w+\.\w+)),\s*$',
    multiLine: true,
  );

  static final RegExp _hex = RegExp('0x([0-9A-Fa-f]{8})');

  /// The color of each field of the [mode] instance, `light` or `dark`, in
  /// [source], the generated library of the scheme class [scheme], with
  /// token references resolved through [symbols]. Fields keep their order.
  static Map<String, int> read(
    String source,
    String scheme,
    Map<String, LockSymbol> symbols,
    String mode,
  ) {
    final start = source.indexOf('static const $scheme $mode = $scheme(');
    if (start < 0) return const {};
    final end = source.indexOf('\n  );', start);
    final block = source.substring(start, end < 0 ? source.length : end);
    return {
      for (final m in _field.allMatches(block))
        if (m.group(3) ??
                _hex.firstMatch(symbols[m.group(4)]?.value ?? '')?.group(1)
            case final hex?)
          m.group(1)!: int.parse(hex, radix: 16),
    };
  }
}
