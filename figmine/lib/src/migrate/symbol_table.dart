import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/token_dart_types.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/lock/lock_symbol.dart';

/// Lists every constant the generated token libraries declare.
abstract final class SymbolTable {
  /// Symbols of [index], keyed as `Class.member`.
  static Map<String, LockSymbol> of(TokenIndex index) => {
    for (final entry in index.entries)
      '${entry.address.className}.${entry.address.member}': (
        token: '${entry.collection.name}/${entry.token.name}',
        mode: entry.collection.multiMode ? entry.mode : null,
        type: TokenDartTypes.of[entry.token.type]!,
        value: DartSource.value(entry.token.values[entry.mode]!.value),
        id: entry.token.variableId,
      ),
  };
}
