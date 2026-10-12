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

/// Writes the libraries of a collection: one per group class, with a
/// constant per token, and one with the catalogue lists.
abstract final class CollectionWriter {
  /// The library sources of [collection], by path.
  static Map<String, String> write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection collection, {
    Map<String, Map<String, LockSymbol>> deprecated = const {},
  }) {
    final classes = <String, List<IndexEntry>>{};
    for (final entry in index.entries) {
      if (entry.collection != collection) continue;
      classes.putIfAbsent(entry.address.className, () => []).add(entry);
    }
    final modes = collection.modes.join(', ');
    final doc = ['Figma collection `${collection.name}`. Modes: $modes.'];
    return {
      for (final MapEntry(key: name, value: entries) in classes.entries)
        entries.first.address.file: [
          context.header(imports: _imports(context, index, entries), doc: doc),
          '\n',
          _class(index, name, entries),
          DeprecatedMembers.write(deprecated[name] ?? const {}),
          '}\n',
        ].join(),
      ...CatalogueWriter.write(context, index, collection),
    };
  }

  static List<String> _imports(
    CodegenContext context,
    TokenIndex index,
    List<IndexEntry> entries,
  ) {
    final own = entries.first.address.file;
    return {
      for (final entry in entries) ...[
        if (!TokenDartTypes.core.contains(entry.token.type))
          context.materialImport,
        if (ValueExpressions.of(index, _value(entry)).file case final f?
            when f != own)
          context.uriOfFile(f),
      ],
    }.toList();
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
