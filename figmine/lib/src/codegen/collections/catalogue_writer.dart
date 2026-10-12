import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/codegen/emit/token_address.dart';
import 'package:figmine/src/codegen/emit/token_dart_types.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Writes the catalogue lists of a collection, one per token type.
abstract final class CatalogueWriter {
  /// Returns the constant name of the [type] catalogue of [collection].
  static String nameOf(
    CodegenContext context,
    TokenCollection collection,
    TokenType type,
  ) {
    return DartIdentifier.camel([
      context.prefix,
      collection.name,
      type.name,
      'tokens',
    ]);
  }

  /// A library per catalogue list of [collection], by path.
  static Map<String, String> write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection collection,
  ) => {
    for (final type in TokenType.values)
      if (index.entries
              .where((e) => e.collection == collection && e.token.type == type)
              .toList()
          case final entries when entries.isNotEmpty)
        index.libraryOf(collection.name, nameOf(context, collection, type)):
            _list(context, collection, type, entries),
  };

  static String _list(
    CodegenContext context,
    TokenCollection collection,
    TokenType type,
    List<IndexEntry> entries,
  ) {
    final summary =
        'Every ${type.name} token of the Figma collection '
        '`${collection.name}`, for galleries and checks against Figma.';
    final buffer =
        StringBuffer(
            context.header(
              imports: {
                'package:figmine/figmine.dart',
                if (!TokenDartTypes.core.contains(type)) context.materialImport,
                for (final e in entries) context.uriOfFile(e.address.file),
              }.toList(),
            ),
          )
          ..writeln()
          ..write(DocComment.render([summary]))
          ..writeln(
            'const List<FigmineTokenEntry<${TokenDartTypes.of[type]}>> '
            '${nameOf(context, collection, type)} = [',
          );
    for (final entry in entries) {
      final value = entry.token.values[entry.mode]!;
      final description = entry.token.description;
      final args = [
        'collection: ${DartSource.string(collection.name)}',
        'path: ${DartSource.string(entry.token.name)}',
        'value: ${entry.address.className}.${entry.address.member}',
        if (collection.multiMode) 'mode: ${DartSource.string(entry.mode)}',
        if (description.isNotEmpty)
          'description: ${DartSource.string(description)}',
        if (value.alias != null)
          'aliases: ${DartSource.string(value.alias!.label)}',
      ];
      buffer.writeln('  ${DartSource.call('FigmineTokenEntry', args)},');
    }
    return (buffer..writeln('];')).toString();
  }
}
