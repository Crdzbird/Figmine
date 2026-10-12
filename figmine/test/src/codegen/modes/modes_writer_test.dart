import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/file_layout.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/modes/mode_breakpoints.dart';
import 'package:figmine/src/codegen/modes/modes_writer.dart';
import 'package:figmine/src/codegen/modes/size_class.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

String _write(TokenCollection collection) {
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
  return ModesWriter.write(context, index, collection);
}

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
    expect(ModesWriter.applies(collection, const TokensConfig()), isTrue);
    final source = _write(collection);
    expect(source, contains('enum AppResponsiveModes {'));
    expect(source, contains('  mobile('));
    expect(source, contains('if (width < 600) return mobile;'));
    expect(source, contains('AppResponsiveModes get appResponsive =>'));
  });

  test('modes of plain values need no Flutter import', () {
    const collection = TokenCollection(
      name: 'Font theme',
      modes: ['Baseline', 'Wireframe'],
      tokens: [
        DesignToken(
          path: ['Brand'],
          type: TokenType.string,
          values: {
            'Baseline': TokenValue('Roboto'),
            'Wireframe': TokenValue('Inter'),
          },
        ),
      ],
    );
    expect(_write(collection), isNot(contains('material')));
  });
}
