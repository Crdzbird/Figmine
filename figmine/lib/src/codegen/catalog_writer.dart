import 'package:figmine/src/codegen/catalogue_writer.dart';
import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/tokens/token_set.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Writes the list of every token catalogue, for `FigmineGallery`.
abstract final class CatalogWriter {
  /// Returns the library source.
  static String write(CodegenContext context, TokenIndex index, TokenSet set) {
    final names = <String>[];
    final imports = {'package:figmine/figmine.dart'};
    for (final collection in set.collections) {
      final types = {
        for (final e in index.entries)
          if (e.collection == collection) e.token.type,
      };
      for (final type in TokenType.values.where(types.contains)) {
        names.add(CatalogueWriter.nameOf(context, collection, type));
        imports.add(context.uriOfFile(index.fileOf[collection.name]!));
      }
    }
    final name = DartIdentifier.camel([context.prefix, 'token', 'catalog']);
    return '''
${context.header(imports: imports.toList())}
/// Every token catalogue of the design, for `FigmineGallery` and checks
/// against Figma.
const List<List<FigmineTokenEntry<Object>>> $name = [
${names.map((n) => '  $n,\n').join()}];
''';
  }
}
