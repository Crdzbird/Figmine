import 'package:figmine/src/codegen/collections/catalog_writer.dart';
import 'package:figmine/src/codegen/collections/collection_writer.dart';
import 'package:figmine/src/codegen/collections/components_writer.dart';
import 'package:figmine/src/codegen/collections/icons_writer.dart';
import 'package:figmine/src/codegen/emit/deprecated_members.dart';
import 'package:figmine/src/codegen/emit/emit_plan.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/codegen/emit/generated_file.dart';
import 'package:figmine/src/codegen/modes/modes_writer.dart';
import 'package:figmine/src/codegen/scheme/color_scheme_writer.dart';
import 'package:figmine/src/codegen/scheme/context_writer.dart';
import 'package:figmine/src/codegen/themes/component_themes_writer.dart';
import 'package:figmine/src/codegen/typography/typography_writer.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/naming/token_naming.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Produces every generated Dart library for a [TokenSet].
abstract final class CodeEmitter {
  /// Name of the barrel file that exports every generated library.
  static const String barrel = 'figmine.g.dart';

  /// Returns the Dart files, with paths relative to the project root.
  static List<GeneratedFile> emit({
    required FigmineConfig config,
    required TokenSet tokens,
    required ProjectInfo project,
    Map<String, LockSymbol> deprecated = const {},
  }) {
    final (:context, :index, :fields) = EmitPlanner.plan(
      config,
      tokens,
      project,
    );
    final kept = DeprecatedMembers.byClass(deprecated);
    final live = {for (final e in index.entries) e.address.className};
    final icons = config.icons;
    String at(FixedFile file) => context.fileOf(file);
    final sources = <String, String>{
      for (final collection in tokens.collections)
        index.fileOf[collection.name]!: CollectionWriter.write(
          context,
          index,
          collection,
          deprecated: kept,
        ),
      at(FixedFile.colorScheme): ColorSchemeWriter.write(context, fields),
      at(FixedFile.textStyles): TypographyWriter.write(
        context,
        tokens.textStyles,
        config.typography,
      ),
      at(FixedFile.components): ComponentsWriter.write(
        context,
        tokens.components,
      ),
      at(FixedFile.themeContext): ContextWriter.write(context),
      for (final c in tokens.collections)
        if (ModesWriter.applies(c, config.tokens))
          ModesWriter.path(index, c): ModesWriter.write(context, index, c),
      at(FixedFile.componentThemes): ComponentThemesWriter.write(context),
      at(FixedFile.catalog): CatalogWriter.write(context, index, tokens),
      if (icons != null)
        at(FixedFile.icons): IconsWriter.write(
          context,
          TokenNaming.icons(tokens.icons),
          icons.output,
        ),
    };
    final orphans = DeprecatedMembers.orphans(context, kept, live);
    if (orphans != null) sources[at(FixedFile.deprecated)] = orphans;
    sources[at(FixedFile.barrel)] = context.header(
      exports: [for (final file in sources.keys) context.uriOfFile(file)],
    );
    return [
      for (final entry in sources.entries)
        GeneratedFile(
          path: '${config.output.directory}/${entry.key}',
          contents: entry.value,
        ),
    ];
  }
}
