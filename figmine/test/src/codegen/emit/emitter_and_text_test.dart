import 'package:figmine/src/codegen/emit/code_emitter.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_tokens.dart';

void main() {
  final files = {
    for (final file in CodeEmitter.emit(
      config: const FigmineConfig(
        fileKey: 'KEY',
        icons: IconsConfig(nodeIds: ['1:2']),
      ),
      tokens: sampleTokens,
      project: const ProjectInfo(modernConstructors: true),
    ))
      file.path.replaceFirst('lib/theme/tokens/', ''): file.contents,
  };

  test('emits one library per class and list plus the shared ones', () {
    expect(files.keys, [
      'color/primitives/app_primitives_palette_blue.g.dart',
      'color/primitives/app_primitives_radius.g.dart',
      'color/primitives/app_primitives_color_tokens.g.dart',
      'color/primitives/app_primitives_number_tokens.g.dart',
      'color/semantic/app_semantic_light.g.dart',
      'color/semantic/app_semantic_dark.g.dart',
      'color/semantic/app_semantic_color_tokens.g.dart',
      'color/color_scheme.g.dart',
      'typography/text_styles.g.dart',
      'components/components.g.dart',
      'color/theme_context.g.dart',
      'components/component_themes.g.dart',
      'catalog.g.dart',
      'icons/icons.g.dart',
      'figmine.g.dart',
    ]);
  });

  test('the scheme is a const ThemeExtension with toColorScheme', () {
    final scheme = files['color/color_scheme.g.dart']!;
    expect(scheme, contains('extends ThemeExtension<AppColorScheme>'));
    expect(scheme, contains('const factory({'));
    expect(
      scheme,
      contains('static const AppColorScheme dark = AppColorScheme('),
    );
    expect(scheme, contains('ColorScheme toColorScheme() => ColorScheme('));
    expect(
      scheme,
      contains('brightness: t < 0.5 ? brightness : other.brightness'),
    );
  });

  test('typography maps styles to TextTheme roles', () {
    final typography = files['typography/text_styles.g.dart']!;
    expect(typography, contains('static const TextStyle displayLarge'));
    expect(typography, contains('fontWeight: FontWeight.w700'));
    expect(typography, contains('displayLarge: displayLarge'));
  });

  group(DartSource, () {
    test('formats numbers and splits long strings', () {
      expect(DartSource.number(4), '4');
      expect(DartSource.number(1.5), '1.5');
      final long = DartSource.string('word ' * 20);
      expect(long.split("' '").length, greaterThan(1));
      expect(DartSource.string(r"it's $5"), r"'it\'s \$5'");
    });
  });

  group(DocComment, () {
    test('wraps, escapes and indents', () {
      final doc = DocComment.render([
        DocComment.escape('Use [x] <b>${' word' * 30}'),
        'Second.',
      ], indent: 2);
      expect(doc, contains(r'\[x\] &lt;b&gt;'));
      expect(doc.split('\n').every((l) => l.length <= 80), isTrue);
      expect(doc, contains('  ///\n  /// Second.'));
    });
  });
}
