import 'package:figmine/src/lock/lock_file.dart';
import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/migrate/code_migrator.dart';
import 'package:figmine/src/migrate/symbol_migrations.dart';

/// How a sync changes the code that uses generated symbols.
typedef MigrationPlan = ({
  Map<String, String> renamed,
  Map<String, Set<String>> renamedIn,
  Map<String, LockSymbol> deprecated,
  Map<String, Set<String>> deprecatedIn,
  int removedUnused,
});

/// Decides renames and deprecations between two syncs.
abstract final class Migrations {
  /// A plan that changes nothing.
  static const MigrationPlan none = (
    renamed: {},
    renamedIn: {},
    deprecated: {},
    deprecatedIn: {},
    removedUnused: 0,
  );

  /// Plans the migration from [previous] to the symbols in [next].
  ///
  /// Removed symbols, and symbols deprecated earlier, stay as deprecated
  /// constants while the code in [migrator] still uses them.
  static Future<MigrationPlan> plan({
    required LockFile? previous,
    required Map<String, LockSymbol> next,
    required CodeMigrator migrator,
  }) async {
    if (previous == null || previous.symbols.isEmpty) return none;
    final changes = SymbolMigrations.between(previous.symbols, next);
    final candidates = {
      ...changes.removed,
      for (final entry in previous.deprecated.entries)
        if (!next.containsKey(entry.key)) entry.key: entry.value,
    };
    final usages = await migrator.usages([
      ...changes.renamed.keys,
      ...candidates.keys,
    ]);
    final deprecated = {
      for (final entry in candidates.entries)
        if (usages[entry.key]?.isNotEmpty ?? false) entry.key: entry.value,
    };
    return (
      renamed: changes.renamed,
      renamedIn: {for (final old in changes.renamed.keys) old: ?usages[old]},
      deprecated: deprecated,
      deprecatedIn: {for (final s in deprecated.keys) s: usages[s]!},
      removedUnused: candidates.length - deprecated.length,
    );
  }
}
