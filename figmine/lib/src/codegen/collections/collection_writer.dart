import 'package:figmine/src/codegen/collections/catalogue_writer.dart';
import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/deprecated_members.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/codegen/emit/token_address.dart';
import 'package:figmine/src/codegen/emit/token_dart_types.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/emit/value_expressions.dart';
import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// Writes one library per collection: a class per group with a constant
/// per token, followed by the catalogue lists.
abstract final class CollectionWriter {
  /// Returns the library source of [collection].
  static String write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection collection, {
    Map<String, Map<String, LockSymbol>> deprecated = const {},
  }) {
    final own = index.fileOf[collection.name];
    final entries = index.entries.where((e) => e.collection == collection);
    final classes = <String, List<IndexEntry>>{};
    final imports = <String>{'package:figmine/figmine.dart'};
    for (final entry in entries) {
      classes.putIfAbsent(entry.address.className, () => []).add(entry);
      if (!TokenDartTypes.core.contains(entry.token.type)) {
        imports.add(context.materialImport);
      }
      final file = ValueExpressions.of(index, _value(entry)).file;
      if (file != null && file != own) imports.add(context.uriOfFile(file));
    }
    final modes = collection.modes.join(', ');
    final buffer = StringBuffer(
      context.header(
        imports: imports.toList(),
        doc: ['Figma collection `${collection.name}`. Modes: $modes.'],
      ),
    );
    for (final group in classes.entries) {
      buffer
        ..writeln()
        ..write(_class(index, group.key, group.value))
        ..write(DeprecatedMembers.write(deprecated[group.key] ?? const {}))
        ..writeln('}');
    }
    buffer.write(CatalogueWriter.write(context, index, collection));
    return buffer.toString();
  }

  static String _class(
    TokenIndex index,
    String className,
    List<IndexEntry> entries,
  ) {
    final first = entries.first;
    final group = first.token.group.join('/');
    final mode = first.collection.multiMode ? ', mode `${first.mode}`' : '';
    final buffer = StringBuffer(
      DocComment.render([
        'Figma group `${group.isEmpty ? first.collection.name : group}`$mode.',
      ]),
    )..writeln('abstract final class $className {');
    for (final entry in entries) {
      final value = _value(entry);
      final type = TokenDartTypes.of[entry.token.type];
      final expression = ValueExpressions.of(index, value).code;
      buffer
        ..write(_doc(entry))
        ..writeln('  static const $type ${entry.address.member} = $expression;')
        ..writeln();
    }
    return buffer.toString();
  }

  static String _doc(IndexEntry entry) {
    final alias = _value(entry).alias;
    return DocComment.render([
      DocComment.escape(entry.token.description),
      'Figma `${entry.token.name}`.',
      if (alias != null) 'Aliases `${alias.label}`.',
    ], indent: 2);
  }

  static TokenValue _value(IndexEntry entry) => entry.token.values[entry.mode]!;
}
