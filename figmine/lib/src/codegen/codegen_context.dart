import 'package:figmine/src/codegen/file_layout.dart';
import 'package:figmine/src/codegen/fixed_file.dart';
import 'package:figmine/src/codegen/library_header.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Names and imports shared by every code writer.
final class CodegenContext {
  /// Creates a context for classes named with [prefix].
  const factory({
    required String prefix,
    required ProjectInfo project,
    required FigmaFileMeta meta,
    required FileLayout layout,
    String directory,
  }) = CodegenContext._;

  const new _({
    required this.prefix,
    required this.project,
    required this.meta,
    required this.layout,
    this.directory = 'lib/theme',
  });

  /// Class name prefix, for example `App`.
  final String prefix;

  /// Facts about the consuming project.
  final ProjectInfo project;

  /// Where each generated library lives.
  final FileLayout layout;

  /// Import that provides Material.
  String get materialImport => project.materialImport;

  /// Start of the public const factory of [className].
  String publicFactory(String className) =>
      project.modernConstructors ? 'const factory' : 'const factory $className';

  /// Start of the private const constructor of [className].
  String privateConstructor(String className) =>
      project.modernConstructors ? 'const new _' : 'const $className._';

  /// The source Figma file.
  final FigmaFileMeta meta;

  /// Output directory, relative to the project.
  final String directory;

  /// Name of the ThemeExtension with the color scheme.
  String get colorSchemeClass => '${prefix}ColorScheme';

  /// Name of the class with the text styles.
  String get typographyClass => '${prefix}Typography';

  /// Name of the class with component dimensions.
  String get componentsClass => '${prefix}Components';

  /// Name of the component themes class.
  String get componentThemesClass => '${prefix}ComponentThemes';

  /// Name of the icon asset class.
  String get iconsClass => '${prefix}Icons';

  /// Name of the BuildContext extension.
  String get contextExtension => '${prefix}ThemeContext';

  /// Getter that exposes the color scheme on BuildContext.
  String get colorSchemeGetter =>
      '${DartIdentifier.camel([prefix])}ColorScheme';

  /// Path of the fixed library [file], relative to the output directory.
  String fileOf(FixedFile file) => layout.fixed(file);

  /// URI that imports the fixed library [file].
  String uriOf(FixedFile file) => uriOfFile(fileOf(file));

  /// URI that imports the generated [file] of the output directory.
  ///
  /// Uses a `package:` URI when the output lives under `lib/`.
  String uriOfFile(String file) {
    final name = project.packageName;
    if (name == null || !directory.startsWith('lib/')) return file;
    return 'package:$name/${directory.substring(4)}/$file';
  }

  /// Header that starts every generated library.
  String header({
    List<String> imports = const [],
    List<String> exports = const [],
    List<String> doc = const [],
  }) =>
      LibraryHeader.render(meta, imports: imports, exports: exports, doc: doc);
}
