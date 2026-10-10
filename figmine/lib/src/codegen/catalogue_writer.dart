import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/doc_comment.dart';
import 'package:figmine/src/codegen/token_dart_types.dart';
import 'package:figmine/src/codegen/token_index.dart';
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

  /// Returns the catalogue source of [collection].
  static String write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection collection,
  ) {
    final buffer = StringBuffer();
    for (final type in TokenType.values) {
      final entries = index.entries
          .where((e) => e.collection == collection && e.token.type == type)
          .toList();
      if (entries.isEmpty) continue;
      final dartType = TokenDartTypes.of[type]!;
      final summary =
          'Every ${type.name} token of the Figma collection '
          '`${collection.name}`, for galleries and checks against Figma.';
      buffer
        ..writeln()
        ..write(DocComment.render([summary]))
        ..writeln(
          'const List<FigmineTokenEntry<$dartType>> '
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
      buffer.writeln('];');
    }
    return buffer.toString();
  }
}
