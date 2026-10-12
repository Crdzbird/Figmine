import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/codegen/scheme/extension_methods_writer.dart';
import 'package:figmine/src/codegen/scheme/material_roles.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme/scheme_parts.dart';
import 'package:figmine/src/codegen/states/state_groups.dart';

/// Writes the color scheme ThemeExtension: every Material role plus the
/// extra roles of the design system, with light and dark presets, and a
/// group per component with the colors of its states.
abstract final class ColorSchemeWriter {
  /// The libraries of the scheme and of its component groups, by path.
  static Map<String, String> write(
    CodegenContext context,
    List<SchemeField> fields,
  ) {
    final name = context.colorSchemeClass;
    final parts = SchemeParts(context, fields);
    final all = parts.fields;
    final buffer = StringBuffer(context.header(imports: parts.imports))
      ..writeln()
      ..write(DocComment.render([_summary, _usage(context)]))
      ..writeln('final class $name extends ThemeExtension<$name> {')
      ..writeln('  /// Creates a color scheme.')
      ..writeln(
        '  ${context.publicFactory(name)}'
        '${_params(all, (f) => '${f.type} ${f.name}')} = $name._;',
      )
      ..writeln()
      ..writeln(
        '  ${context.privateConstructor(name)}'
        '${_params(all, (f) => 'this.${f.name}')};',
      )
      ..writeln()
      ..write(parts.preset('light', (f) => f.light.code))
      ..write(parts.preset('dark', (f) => f.dark.code))
      ..writeln('  /// Whether this is the light or the dark scheme.')
      ..writeln('  final Brightness brightness;')
      ..writeln();
    for (final f in parts.roles) {
      buffer
        ..write(DocComment.render([f.doc], indent: 2))
        ..writeln('  final Color ${f.name};')
        ..writeln();
    }
    for (final kind in parts.groups.keys) {
      buffer
        ..writeln('  /// The colors of the `$kind` component in each state.')
        ..writeln('  final ${parts.group(kind)} ${StateGroups.accessor(kind)};')
        ..writeln();
    }
    final material = [
      'brightness: brightness',
      for (final role in MaterialRoles.colorScheme) '$role: $role',
    ];
    buffer
      ..writeln('  /// The Material [ColorScheme] with the same roles.')
      ..writeln(
        '  ColorScheme toColorScheme() => '
        '${DartSource.call('ColorScheme', material)};',
      )
      ..writeln()
      ..write(ExtensionMethodsWriter.copyWith(name, all))
      ..writeln()
      ..write(ExtensionMethodsWriter.lerp(name, all))
      ..writeln('}');
    return {
      context.fileOf(FixedFile.colorScheme): buffer.toString(),
      ...parts.libraries,
    };
  }

  static const String _summary =
      'The color scheme of the design system: every Material role plus '
      'the extra roles defined in Figma, as a [ThemeExtension].';

  static String _usage(CodegenContext context) =>
      'Read it with `context.${context.colorSchemeGetter}` and convert it '
      'with [toColorScheme] for [ThemeData.colorScheme].';

  static String _params(
    List<ExtensionField> fields,
    String Function(ExtensionField field) param,
  ) => DartSource.params([for (final f in fields) 'required ${param(f)}']);
}
