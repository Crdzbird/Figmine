import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/codegen/emit/fixed_file.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/states/state_groups.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Writes a class per component with the colors of each of its states.
abstract final class StateColorsWriter {
  /// The library path of the group class [className], in a `states`
  /// folder next to the color scheme.
  static String path(CodegenContext context, String className) {
    final scheme = context.fileOf(FixedFile.colorScheme);
    final folder = scheme.substring(0, scheme.lastIndexOf('/') + 1);
    return '${folder}states/${DartIdentifier.snake([className])}.g.dart';
  }

  /// The library of the group of [kind] with its [fields].
  static String write(
    CodegenContext context,
    String kind,
    List<SchemeField> fields,
  ) {
    final name = StateGroups.className(context.prefix, kind);
    final names = [for (final f in fields) StateGroups.member(f.name, kind)];
    final imports = {
      context.materialImport,
      for (final f in fields) ...[?f.light.file, ?f.dark.file],
    }.map((u) => u.startsWith('package:') ? u : context.uriOfFile(u));
    String each(String Function(String m) line) =>
        DartSource.params([for (final m in names) line(m)]);
    String call(String Function(String m, SchemeField f) arg) =>
        DartSource.call(name, [
          for (var i = 0; i < fields.length; i++) arg(names[i], fields[i]),
        ]);
    String preset(String mode, String Function(SchemeField f) pick) =>
        '  /// The colors for the $mode theme.\n'
        '  static const $name $mode = ${call((m, f) => '$m: ${pick(f)}')};\n\n';
    final lerp = context.project.modernConstructors ? 'lerp' : '$name.lerp';
    final summary =
        'The colors of the `$kind` component in each state, from its '
        'Figma variants or derived from the scheme.';
    final buffer = StringBuffer(context.header(imports: imports.toList()))
      ..writeln()
      ..write(DocComment.render([summary]))
      ..writeln('final class $name {')
      ..writeln('  /// Creates the colors.')
      ..writeln(
        '  ${context.publicFactory(name)}'
        '${each((m) => 'required Color $m')} = $name._;',
      )
      ..writeln()
      ..writeln(
        '  ${context.privateConstructor(name)}'
        '${each((m) => 'required this.$m')};',
      )
      ..writeln()
      ..writeln('  /// The colors between [a] and [b] at [t].')
      ..writeln('  factory $lerp($name a, $name b, double t) =>')
      ..writeln('      ${call((m, _) => '$m: Color.lerp(a.$m, b.$m, t)!')};')
      ..writeln()
      ..write(preset('light', (f) => f.light.code))
      ..write(preset('dark', (f) => f.dark.code));
    for (var i = 0; i < fields.length; i++) {
      buffer
        ..write(DocComment.render([fields[i].doc], indent: 2))
        ..writeln('  final Color ${names[i]};')
        ..writeln();
    }
    return (buffer
          ..writeln('  /// A copy with the given colors replaced.')
          ..writeln('  $name copyWith${each((m) => 'Color? $m')} =>')
          ..writeln('      ${call((m, _) => '$m: $m ?? this.$m')};')
          ..writeln('}'))
        .toString();
  }
}
