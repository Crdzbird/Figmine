import 'package:figmine/src/codegen/emit/code_emitter.dart';
import 'package:figmine/src/config/output_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Names and imports for the theme scaffold.
final class ScaffoldContext {
  /// Creates a context from the output settings and project facts.
  const factory({required OutputConfig output, required ProjectInfo project}) =
      ScaffoldContext._;

  const new _({required this.output, required this.project});

  /// Output settings.
  final OutputConfig output;

  /// Facts about the consuming project.
  final ProjectInfo project;

  /// Class name prefix.
  String get prefix => output.classPrefix;

  /// Name of the theme class.
  String get themeClass => '${prefix}Theme';

  /// Name of the generated color scheme class.
  String get schemeClass => '${prefix}ColorScheme';

  /// Name of the generated component dimensions class.
  String get componentsClass => '${prefix}Components';

  /// Name of the generated component themes class.
  String get componentThemesClass => '${prefix}ComponentThemes';

  /// Name of the generated typography class.
  String get typographyClass => '${prefix}Typography';

  /// File name of the theme class.
  String get themeFile => '${DartIdentifier.snake([themeClass])}.dart';

  /// Import of the material library.
  String get material => project.materialImport;

  /// Import of the generated tokens barrel.
  String get tokens => uriOf(output.directory, CodeEmitter.barrel);

  /// Import of the scaffold file [file].
  String theme(String file) => uriOf(output.themeDirectory, file);

  /// A `package:` URI for [file] in [directory] when under `lib/`.
  String uriOf(String directory, String file) {
    final name = project.packageName;
    if (name == null || !directory.startsWith('lib/')) return file;
    return 'package:$name/${directory.substring(4)}/$file';
  }

  /// Sorted import directives for [uris].
  String imports(List<String> uris) {
    final sorted = [...uris]..sort();
    return sorted.map((uri) => "import '$uri';\n").join();
  }

  /// Start of the public const factory of [className].
  String publicFactory(String className) =>
      project.modernConstructors ? 'const factory' : 'const factory $className';

  /// Start of the private const constructor of [className].
  String privateConstructor(String className) =>
      project.modernConstructors ? 'const new _' : 'const $className._';
}
