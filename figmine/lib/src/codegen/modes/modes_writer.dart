import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/token_dart_types.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/modes/modes_members.dart';
import 'package:figmine/src/codegen/modes/modes_plan.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Writes a class that switches between the modes of a collection, such
/// as breakpoints or brands, at runtime.
abstract final class ModesWriter {
  /// Whether [c] gets a modes class: several modes that are not only the
  /// light and dark modes the color scheme already uses.
  static bool applies(TokenCollection c, TokensConfig config) {
    if (!c.multiMode) return false;
    final picked = CollectionModes.pick(c.modes, config);
    return c.modes.length != 2 || picked.light == picked.dark;
  }

  /// The library of the modes class of [c] and, for breakpoints, the
  /// library of its context getter, by path, next to its tokens.
  static Map<String, String> write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection c,
  ) {
    final p = ModesPlanner.plan(context, index, c);
    String at(String name) =>
        '${index.folderOf[c.name]}/${DartIdentifier.snake([name])}.g.dart';
    final tokens = {
      for (final mode in c.modes)
        for (final f in p.fields)
          if (index.find(c.name, f.token.name, mode) case final a?)
            context.uriOfFile(a.file),
    };
    final getter = ModesMembers.context(p);
    return {
      at(p.cls): [
        context.header(
          imports: [if (_flutter(p)) context.materialImport, ...tokens],
        ),
        '/// The values of Figma collection `${c.name}` in one mode, to switch',
        '/// at runtime: ${c.modes.join(', ')}.',
        'enum ${p.cls} {',
        ...ModesMembers.values(p, index, c),
        '',
        '  new({',
        '    required this.mode,',
        for (final f in p.fields) '    required this.${f.name},',
        '  });',
        '',
        '  /// The Figma mode.',
        '  final String mode;',
        for (final f in p.fields) ...[
          '',
          '  /// Figma `${f.token.name}`.',
          '  final ${f.type} ${f.name};',
        ],
        ...ModesMembers.lines(p),
        '',
      ].join('\n'),
      if (getter != null)
        at('${p.cls}Context'): [
          context.header(
            imports: [context.materialImport, context.uriOfFile(at(p.cls))],
          ),
          ...getter,
          '',
        ].join('\n'),
    };
  }

  /// Whether the class needs Flutter for a value type, such as `Color`.
  static bool _flutter(ModesPlan p) =>
      p.fields.any((f) => !TokenDartTypes.core.contains(f.token.type));
}
