import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/doc_comment.dart';
import 'package:figmine/src/codegen/extension_methods_writer.dart';
import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';

/// Writes the color scheme ThemeExtension: every Material role plus the
/// extra roles of the design system, with light and dark presets.
abstract final class ColorSchemeWriter {
  /// Returns the library source for [fields].
  static String write(CodegenContext context, List<SchemeField> fields) {
    final name = context.colorSchemeClass;
    final imports = {
      context.materialImport,
      for (final f in fields) ...[?f.light.file, ?f.dark.file],
    }.map((u) => u.startsWith('package:') ? u : context.uriOfFile(u));
    final all = <ExtensionField>[
      (name: 'brightness', type: 'Brightness'),
      for (final f in fields) (name: f.name, type: 'Color'),
    ];
    final buffer = StringBuffer(context.header(imports: imports.toList()))
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
      ..write(_preset(name, 'light', fields, (f) => f.light.code))
      ..write(_preset(name, 'dark', fields, (f) => f.dark.code))
      ..writeln('  /// Whether this is the light or the dark scheme.')
      ..writeln('  final Brightness brightness;')
      ..writeln();
    for (final f in fields) {
      buffer
        ..write(DocComment.render([f.doc], indent: 2))
        ..writeln('  final Color ${f.name};')
        ..writeln();
    }
    final roles = [
      'brightness: brightness',
      for (final role in MaterialRoles.colorScheme) '$role: $role',
    ];
    return (buffer
          ..writeln('  /// The Material [ColorScheme] with the same roles.')
          ..writeln(
            '  ColorScheme toColorScheme() => '
            '${DartSource.call('ColorScheme', roles)};',
          )
          ..writeln()
          ..write(ExtensionMethodsWriter.copyWith(name, all))
          ..writeln()
          ..write(ExtensionMethodsWriter.lerp(name, all))
          ..writeln('}'))
        .toString();
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

  static String _preset(
    String name,
    String mode,
    List<SchemeField> fields,
    String Function(SchemeField field) pick,
  ) {
    final args = [
      'brightness: Brightness.$mode',
      for (final f in fields) '${f.name}: ${pick(f)}',
    ];
    return '  /// The scheme for the $mode theme.\n'
        '  static const $name $mode = ${DartSource.call(name, args)};\n\n';
  }
}
