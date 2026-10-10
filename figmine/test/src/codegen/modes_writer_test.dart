import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/file_layout.dart';
import 'package:figmine/src/codegen/mode_breakpoints.dart';
import 'package:figmine/src/codegen/modes_writer.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('breakpoint modes map onto window size classes, apps first', () {
    expect(ModeBreakpoints.of(['Desktop', 'Mobile', 'Tablet']), {
      SizeClass.compact: 'Mobile',
      SizeClass.medium: 'Tablet',
      SizeClass.expanded: 'Desktop',
    });
    expect(
      ModeBreakpoints.of([
        'Apps Mobile',
        'Apps Tablet',
        'Desktop',
        'Mobile',
      ])![SizeClass.compact],
      'Apps Mobile',
    );
    expect(ModeBreakpoints.of(['Brand A', 'Brand B']), isNull);
  });

  test('multi mode collections get a switchable modes class', () {
    const collection = TokenCollection(
      name: 'Responsive',
      modes: ['Desktop', 'Mobile'],
      tokens: [
        DesignToken(
          path: ['Root Font Size'],
          type: TokenType.number,
          values: {'Desktop': TokenValue(16.0), 'Mobile': TokenValue(14.0)},
        ),
      ],
    );
    const config = TokensConfig();
    final layout = FileLayout();
    final index = TokenIndex(
      collections: [collection],
      prefix: 'App',
      config: config,
      layout: layout,
    );
    final context = CodegenContext(
      prefix: 'App',
      project: const ProjectInfo(packageName: 'app'),
      meta: const FigmaFileMeta(name: 'F', version: '1', lastModified: ''),
      layout: layout,
      directory: 'lib/theme/tokens',
    );
    expect(ModesWriter.applies(collection, config), isTrue);
    final source = ModesWriter.write(context, index, collection);
    expect(source, contains('enum AppResponsiveModes {'));
    expect(source, contains('  mobile('));
    expect(source, contains('if (width < 600) return mobile;'));
    expect(source, contains('AppResponsiveModes get appResponsive =>'));
  });
}
