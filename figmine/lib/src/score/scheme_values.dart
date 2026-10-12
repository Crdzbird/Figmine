import 'package:figmine/src/codegen/states/state_groups.dart';
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
  /// token references resolved through [symbols]. Component groups are
  /// read from their libraries in [groups], by class, under the flat names
  /// of their fields, such as `buttonHovered`. Fields keep their order.
  static Map<String, int> read(
    String source,
    String scheme,
    Map<String, LockSymbol> symbols,
    String mode, {
    Map<String, String> groups = const {},
  }) {
    final start = source.indexOf('static const $scheme $mode = $scheme(');
    if (start < 0) return const {};
    final end = source.indexOf('\n  );', start);
    final block = source.substring(start, end < 0 ? source.length : end);
    final values = <String, int>{};
    for (final m in _field.allMatches(block)) {
      final owner = m.group(4)?.split('.').first;
      if (groups[owner] case final group?) {
        final kind = StateGroups.kindOfAccessor(m.group(1)!);
        for (final e in read(group, owner!, symbols, mode).entries) {
          values[StateGroups.field(kind, e.key)] = e.value;
        }
        continue;
      }
      if (m.group(3) ??
              _hex.firstMatch(symbols[m.group(4)]?.value ?? '')?.group(1)
          case final hex?) {
        values[m.group(1)!] = int.parse(hex, radix: 16);
      }
    }
    return values;
  }
}
