import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/collection_writer.dart';
import 'package:figmine/src/codegen/file_layout.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';

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
    test('writes typed constants with Figma docs', () {
      final source = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.first,
      );
      expect(source, contains('abstract final class AppPrimitivesPaletteBlue'));
      expect(source, contains('static const Color v500 = Color(0xFF0000FF);'));
      expect(source, contains('static const double m = 12;'));
      expect(source, contains('/// Brand blue.'));
      expect(source, contains('/// Figma `palette/blue/500`.'));
    });

    test('references aliases across files and documents them', () {
      final source = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.last,
      );
      expect(source, contains('/// Figma group `Semantic`, mode `Light`.'));
      expect(
        source,
        contains('static const Color primary = AppPrimitivesPaletteBlue.v500;'),
      );
      expect(source, contains('/// Aliases `palette/blue/500 (Primitives)`.'));
      expect(
        source,
        contains("import 'package:my_app/theme/color/primitives.g.dart';"),
      );
    });

    test('writes typed catalogues', () {
      final source = CollectionWriter.write(
        context,
        index,
        sampleTokens.collections.last,
      );
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
