import 'package:figmine/src/codegen/collections/collection_domain.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/config/output_layout.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Decides the path of every generated library, relative to the output
/// directory.
final class FileLayout {
  /// Creates the layout. Fixed libraries are reserved first.
  factory([OutputLayout layout]) = FileLayout._;

  new _([this.layout = OutputLayout.domain]) {
    for (final file in FixedFile.values) {
      _paths.claim(fixed(file));
    }
  }

  /// The chosen organization.
  final OutputLayout layout;

  final UniqueNamer _paths = UniqueNamer();

  /// Path of a fixed library.
  String fixed(FixedFile file) => switch ((layout, file)) {
    (_, FixedFile.barrel) => 'figmine.g.dart',
    (_, FixedFile.deprecated) => 'deprecated.g.dart',
    (_, FixedFile.icons) => 'icons/icons.g.dart',
    (_, FixedFile.catalog) => 'catalog.g.dart',
    (OutputLayout.domain, FixedFile.colorScheme) => 'color/color_scheme.g.dart',
    (OutputLayout.domain, FixedFile.themeContext) =>
      'color/theme_context.g.dart',
    (OutputLayout.domain, FixedFile.textStyles) =>
      'typography/text_styles.g.dart',
    (OutputLayout.domain, FixedFile.components) =>
      'components/components.g.dart',
    (OutputLayout.domain, FixedFile.componentThemes) =>
      'components/component_themes.g.dart',
    (OutputLayout.figma, _) =>
      'theme/${DartIdentifier.snake([file.name])}.g.dart',
  };

  /// Path of the library of [collection], unique among all libraries.
  String collection(TokenCollection collection) {
    final stem = switch (layout) {
      OutputLayout.domain => _domain(collection),
      OutputLayout.figma => _figma(collection),
    };
    return '${_paths.claim(stem)}.g.dart';
  }

  static String _domain(TokenCollection collection) {
    final domain = CollectionDomain.of(collection);
    return '$domain/${CollectionDomain.stem(collection, domain)}';
  }

  static String _figma(TokenCollection collection) {
    final name = collection.name;
    if (name.toLowerCase().startsWith('inferred ')) {
      return 'inferred/${DartIdentifier.snake([name.substring(9)])}';
    }
    final parts = [
      for (final segment in name.split('/'))
        if (DartIdentifier.words([segment]).isNotEmpty)
          DartIdentifier.snake([segment]),
    ];
    return 'figma/${parts.isEmpty ? 'tokens' : parts.join('/')}';
  }
}
