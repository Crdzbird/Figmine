import 'package:figmine/src/codegen/collection_writer.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/lock/lock_symbol.dart';

/// Lists every constant the generated token libraries declare.
abstract final class SymbolTable {
  /// Symbols of [index], keyed as `Class.member`.
  static Map<String, LockSymbol> of(TokenIndex index) => {
    for (final entry in index.entries)
      '${entry.address.className}.${entry.address.member}': (
        token: '${entry.collection.name}/${entry.token.name}',
        mode: entry.collection.multiMode ? entry.mode : null,
        type: CollectionWriter.dartTypes[entry.token.type]!,
        value: DartSource.value(entry.token.values[entry.mode]!.value),
        id: entry.token.variableId,
      ),
  };
}
