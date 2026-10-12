import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/codegen/themes/button_theme_source.dart';
import 'package:figmine/src/codegen/themes/control_theme_source.dart';
import 'package:figmine/src/codegen/themes/field_theme_source.dart';
import 'package:figmine/src/codegen/themes/surface_theme_source.dart';
import 'package:figmine/src/codegen/themes/text_theme_source.dart';

/// Writes the component themes that resolve the state colors of the
/// scheme and the measured dimensions.
abstract final class ComponentThemesWriter {
  /// Returns the library source.
  static String write(CodegenContext context) {
    final s = context.colorSchemeClass;
    final m = context.componentsClass;
    final head = context.header(
      imports: [
        context.materialImport,
        context.uriOf(FixedFile.colorScheme),
        context.uriOf(FixedFile.components),
      ],
    );
    return '''
$head
/// Component themes with the colors of each interaction state from Figma
/// and the dimensions measured in the screens.
abstract final class ${context.componentThemesClass} {
${ButtonThemeSource.render(s, m)}
${FieldThemeSource.render(s, m)}
${ControlThemeSource.render(s)}
${TextThemeSource.render(s, m)}
${SurfaceThemeSource.render(s, m)}
}
''';
  }
}
