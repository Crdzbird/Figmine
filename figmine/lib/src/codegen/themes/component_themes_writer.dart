import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/codegen/themes/button_theme_source.dart';
import 'package:figmine/src/codegen/themes/control_theme_source.dart';
import 'package:figmine/src/codegen/themes/field_theme_source.dart';
import 'package:figmine/src/codegen/themes/state_picker_source.dart';
import 'package:figmine/src/codegen/themes/surface_theme_source.dart';
import 'package:figmine/src/codegen/themes/text_theme_source.dart';
import 'package:figmine/src/codegen/themes/theme_spec.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Writes a class per component theme, resolving the state colors of the
/// scheme and the measured dimensions.
abstract final class ComponentThemesWriter {
  /// Every component theme of [context].
  static List<ThemeSpec> specs(CodegenContext context) {
    final m = context.componentsClass;
    final p = context.statePickerClass;
    return [
      ...ButtonThemeSource.specs(m, p),
      ...FieldThemeSource.specs(m, p),
      ...ControlThemeSource.specs(p),
      ...TextThemeSource.specs(m),
      ...SurfaceThemeSource.specs(m),
    ];
  }

  /// The libraries of the themes and of the state picker, by path.
  static Map<String, String> write(CodegenContext context) {
    final folder = context.fileOf(FixedFile.componentThemes);
    String at(String name) => '$folder/${DartIdentifier.snake([name])}.g.dart';
    final picker = at(context.statePickerClass);
    return {
      picker: StatePickerSource.render(context),
      for (final spec in specs(context))
        at(context.themeClass(spec.name)): _theme(context, spec, picker),
    };
  }

  static String _theme(CodegenContext context, ThemeSpec spec, String picker) {
    final name = context.themeClass(spec.name);
    final s = context.colorSchemeClass;
    final head = context.header(
      imports: [
        context.materialImport,
        context.uriOf(FixedFile.colorScheme),
        if (spec.body.contains('${context.componentsClass}.'))
          context.uriOf(FixedFile.components),
        if (spec.body.contains('${context.statePickerClass}.'))
          context.uriOfFile(picker),
      ],
    );
    final params = spec.text ? '$s c, TextTheme t' : '$s c';
    final reads = spec.text ? 'the colors [c] and text theme [t]' : '[c]';
    return '''
$head
${DocComment.render([spec.doc])}abstract final class $name {
  /// The theme from $reads.
  static ${spec.type} of($params) =>
${spec.body};
}
''';
  }
}
