import 'dart:io';

import 'package:figmine/src/codegen/emit/code_emitter.dart';
import 'package:figmine/src/config/output_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/preview/preview_template.dart';
import 'package:figmine/src/scaffold/scaffold_context.dart';
import 'package:path/path.dart' as p;

/// Writes, runs and removes the temporary test that renders the preview.
final class PreviewTestWriter {
  /// Creates a writer for the project at [root].
  const factory({
    required String root,
    required OutputConfig output,
    required ProjectInfo project,
  }) = PreviewTestWriter._;

  const new _({
    required this.root,
    required this.output,
    required this.project,
  });

  /// Project folder.
  final String root;

  /// Where the generated code and the theme scaffold live.
  final OutputConfig output;

  /// Facts about the project.
  final ProjectInfo project;

  ScaffoldContext get _scaffold =>
      ScaffoldContext(output: output, project: project);

  String get _themeFile =>
      p.join(root, output.themeDirectory, _scaffold.themeFile);

  /// Whether generated tokens exist to render.
  bool get ready =>
      File(p.join(root, output.directory, CodeEmitter.barrel)).existsSync();

  /// Renders `light.png` and `dark.png` into [folder]. Returns the test
  /// output on failure, or null.
  Future<String?> render(String folder) async {
    final test = File(p.join(root, '.figmine', 'preview_test.dart'));
    await test.parent.create(recursive: true);
    await test.writeAsString(_source());
    try {
      final result = await Process.run('flutter', [
        'test',
        p.relative(test.path, from: root),
        '--dart-define=FIGMINE_PREVIEW_OUT=$folder',
      ], workingDirectory: root);
      if (result.exitCode == 0) return null;
      return '${result.stdout}\n${result.stderr}';
    } finally {
      await test.delete();
    }
  }

  String _source() {
    final c = _scaffold;
    final theme = File(_themeFile);
    final scaffolded =
        theme.existsSync() &&
        theme.readAsStringSync().contains('class ${c.themeClass}');
    final scheme = c.schemeClass;
    String plain(String mode) =>
        'ThemeData(colorScheme: '
        '$scheme.$mode.toColorScheme(), textTheme: ${c.typographyClass}'
        '.textTheme, extensions: [$scheme.$mode])';
    return PreviewTemplate.render(
      imports: [c.material, c.tokens, if (scaffolded) c.theme(c.themeFile)],
      light: scaffolded ? 'const ${c.themeClass}().themeData' : plain('light'),
      dark: scaffolded
          ? 'const ${c.themeClass}(brightness: Brightness.dark).themeData'
          : plain('dark'),
    );
  }
}
