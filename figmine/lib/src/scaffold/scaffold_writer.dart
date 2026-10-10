import 'package:figmine/src/codegen/generated_file.dart';
import 'package:figmine/src/scaffold/component_templates.dart';
import 'package:figmine/src/scaffold/control_templates.dart';
import 'package:figmine/src/scaffold/scaffold_context.dart';
import 'package:figmine/src/scaffold/theme_template.dart';

/// Produces the theme scaffold: a theme class, component themes and a
/// barrel that also exports the generated tokens.
abstract final class ScaffoldWriter {
  /// Name of the scaffold barrel file.
  static const String barrel = 'theme.dart';

  /// Returns every scaffold file, with paths relative to the project root.
  static List<GeneratedFile> files(ScaffoldContext c) {
    final sources = {
      c.themeFile: ThemeTemplate.render(c),
      for (final entry in {
        ...ComponentTemplates.render(c),
        ...ControlTemplates.render(c),
      }.entries)
        'components/${entry.key}': entry.value,
    };
    final exports = [c.tokens, for (final f in sources.keys) c.theme(f)]
      ..sort();
    sources[barrel] =
        '/// The design system theme: generated tokens and the hand tuned\n'
        '/// component themes built on them.\n'
        'library;\n\n'
        '${exports.map((uri) => "export '$uri';\n").join()}';
    return [
      for (final entry in sources.entries)
        GeneratedFile(
          path: '${c.output.themeDirectory}/${entry.key}',
          contents: entry.value,
        ),
    ];
  }
}
