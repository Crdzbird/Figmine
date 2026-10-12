import 'package:figmine/src/codegen/collections/collection_writer.dart';
import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_tokens.dart';

void main() {
  final context = CodegenContext(
    prefix: 'App',
    project: const ProjectInfo(packageName: 'my_app'),
    meta: sampleMeta,
    layout: FileLayout(),
  );
  final index = TokenIndex(
    collections: sampleTokens.collections,
    prefix: 'App',
    config: const TokensConfig(),
  );

  group(CollectionWriter, () {
    test('writes a library per class with typed constants', () {
      final files = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.first,
      );
      final source =
          files['color/primitives/app_primitives_palette_blue.g.dart']!;
      for (final library in files.values) {
        expect(
          RegExp(
            '^abstract final class',
            multiLine: true,
          ).allMatches(library).length,
          lessThanOrEqualTo(1),
        );
      }
      expect(source, contains('abstract final class AppPrimitivesPaletteBlue'));
      expect(source, contains('static const Color v500 = Color(0xFF0000FF);'));
      expect(files.values.join(), contains('static const double m = 12;'));
      expect(source, contains('/// Brand blue.'));
      expect(source, contains('/// Figma `palette/blue/500`.'));
    });

    test('references aliases across files and documents them', () {
      final source = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.last,
      )['color/semantic/app_semantic_light.g.dart']!;
      expect(source, contains('/// Figma group `Semantic`, mode `Light`.'));
      expect(
        source,
        contains('static const Color primary = AppPrimitivesPaletteBlue.v500;'),
      );
      expect(source, contains('/// Aliases `palette/blue/500 (Primitives)`.'));
      expect(source, contains('primitives/app_primitives_palette_blue.g.dart'));
    });

    test('writes each typed catalogue in its own library', () {
      final source = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.last,
      )['color/semantic/app_semantic_color_tokens.g.dart']!;
      expect(
        source,
        contains(
          'const List<FigmineTokenEntry<Color>> appSemanticColorTokens = [',
        ),
      );
      expect(source, contains("mode: 'Dark'"));
      expect(source, contains("aliases: 'palette/blue/500 (Primitives)'"));
      expect(source, contains("import 'package:figmine/figmine.dart';"));
    });
  });
}
