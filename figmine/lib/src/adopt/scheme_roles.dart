import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/score/scheme_values.dart';

/// Reads the fields of each light color of a generated color scheme.
abstract final class SchemeRoles {
  /// The fields of each light color in [source], the generated library of
  /// the scheme class [scheme], resolving token references with [symbols].
  /// Fields of a color keep their order, so Material roles come before the
  /// extra and component fields.
  static Map<int, List<String>> read(
    String source,
    String scheme,
    Map<String, LockSymbol> symbols,
  ) {
    final roles = <int, List<String>>{};
    for (final e in SchemeValues.read(
      source,
      scheme,
      symbols,
      'light',
    ).entries) {
      (roles[e.value] ??= []).add(e.key);
    }
    return roles;
  }
}
