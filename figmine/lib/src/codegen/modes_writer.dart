import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/modes_members.dart';
import 'package:figmine/src/codegen/modes_plan.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/collection_modes.dart';
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

  /// The library path of the modes class of [c], next to its tokens.
  static String path(TokenIndex index, TokenCollection c) => index
      .fileOf[c.name]!
      .replaceFirst(RegExp(r'\.g\.dart$'), '_modes.g.dart');

  /// The library source of the modes class of [c].
  static String write(
    CodegenContext context,
    TokenIndex index,
    TokenCollection c,
  ) {
    final p = ModesPlanner.plan(context, index, c);
    final file = index.fileOf[c.name]!;
    return [
      context.header(
        imports: [context.materialImport, context.uriOfFile(file)],
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
    ].join('\n');
  }
}
