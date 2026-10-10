import 'package:figmine/src/lock/lock_symbol.dart';

/// What happened to the symbols of the previous sync.
typedef SymbolChanges = ({
  Map<String, String> renamed,
  Map<String, LockSymbol> removed,
});

/// Matches vanished symbols with their new names.
abstract final class SymbolMigrations {
  /// Compares [before] with [after]. A vanished symbol is renamed when its
  /// token, or its Figma variable, still exists in the same mode under
  /// another symbol; otherwise it is removed.
  static SymbolChanges between(
    Map<String, LockSymbol> before,
    Map<String, LockSymbol> after,
  ) {
    String? find(bool Function(LockSymbol s) test) {
      for (final entry in after.entries) {
        if (test(entry.value)) return entry.key;
      }
      return null;
    }

    final renamed = <String, String>{};
    final removed = <String, LockSymbol>{};
    for (final MapEntry(key: name, value: old) in before.entries) {
      if (after.containsKey(name)) continue;
      final id = old.id;
      final target =
          find((s) => s.token == old.token && s.mode == old.mode) ??
          (id == null ? null : find((s) => s.id == id && s.mode == old.mode)) ??
          (id == null ? null : find((s) => s.id == id));
      if (target == null) {
        removed[name] = old;
        continue;
      }
      renamed[name] = target;
    }
    return (renamed: renamed, removed: removed);
  }
}
