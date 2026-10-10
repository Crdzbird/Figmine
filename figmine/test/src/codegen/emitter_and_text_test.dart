import 'package:figmine/src/codegen/code_emitter.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/doc_comment.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/sample_tokens.dart';

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

  test('emits one file per collection plus the shared libraries', () {
    expect(files.keys, [
      'color/primitives.g.dart',
      'color/semantic.g.dart',
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
