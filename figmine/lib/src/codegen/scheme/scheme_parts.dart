import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/scheme/extension_methods_writer.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme/state_colors_writer.dart';
import 'package:figmine/src/codegen/states/state_groups.dart';

/// The fields of the color scheme split into scheme roles and component
/// groups, with what the scheme class needs to declare them.
final class SchemeParts {
  /// Splits [fields] for the scheme of [context].
  factory(CodegenContext context, List<SchemeField> fields) = SchemeParts._;

  new _(this.context, List<SchemeField> fields)
    : roles = [
        for (final f in fields)
          if (StateGroups.kindOf(f.name) == null) f,
      ],
      groups = {
        for (final kind in StateGroups.kinds)
          if (fields.where((f) => StateGroups.kindOf(f.name) == kind).toList()
              case final own when own.isNotEmpty)
            kind: own,
      };

  /// The scheme the fields belong to.
  final CodegenContext context;

  /// The Material and extra roles, declared on the scheme itself.
  final List<SchemeField> roles;

  /// The state fields of each component, by component.
  final Map<String, List<SchemeField>> groups;

  /// The class of the group of [kind].
  String group(String kind) => StateGroups.className(context.prefix, kind);

  /// The library of the group of [kind].
  String path(String kind) => StateColorsWriter.path(context, group(kind));

  /// Imports of the scheme library.
  List<String> get imports => {
    context.materialImport,
    for (final f in roles) ...[?f.light.file, ?f.dark.file],
    for (final kind in groups.keys) path(kind),
  }.map((u) => u.startsWith('package:') ? u : context.uriOfFile(u)).toList();

  /// Every field of the scheme class, the brightness first.
  List<ExtensionField> get fields => [
    (name: 'brightness', type: 'Brightness'),
    for (final f in roles) (name: f.name, type: 'Color'),
    for (final kind in groups.keys)
      (name: StateGroups.accessor(kind), type: group(kind)),
  ];

  /// The preset of [mode], `light` or `dark`, with the values [pick] gives.
  String preset(String mode, String Function(SchemeField f) pick) {
    final name = context.colorSchemeClass;
    final args = [
      'brightness: Brightness.$mode',
      for (final f in roles) '${f.name}: ${pick(f)}',
      for (final kind in groups.keys)
        '${StateGroups.accessor(kind)}: ${group(kind)}.$mode',
    ];
    return '  /// The scheme for the $mode theme.\n'
        '  static const $name $mode = ${DartSource.call(name, args)};\n\n';
  }

  /// The libraries of the component groups, by path.
  Map<String, String> get libraries => {
    for (final MapEntry(key: kind, value: own) in groups.entries)
      path(kind): StateColorsWriter.write(context, kind, own),
  };
}
