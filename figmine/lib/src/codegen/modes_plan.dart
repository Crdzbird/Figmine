import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/mode_breakpoints.dart';
import 'package:figmine/src/codegen/size_class.dart';
import 'package:figmine/src/codegen/token_dart_types.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// A field of a modes class.
typedef ModeField = ({String name, DesignToken token, String type});

/// The names of a modes class: the class, its context getter, its fields,
/// a constant per mode, and the mode of each window size class, if any.
typedef ModesPlan = ({
  String cls,
  String getter,
  List<ModeField> fields,
  Map<String, String> modes,
  Map<SizeClass, String>? sizes,
});

/// Names the members of the modes class of a collection.
abstract final class ModesPlanner {
  /// The plan for the collection [c].
  static ModesPlan plan(
    CodegenContext context,
    TokenIndex index,
    TokenCollection c,
  ) {
    final segment = index.config.segmentOf(c.name);
    final names = UniqueNamer();
    const [
      'mode',
      'all',
      'byMode',
      'of',
      'index',
      'name',
      'values',
    ].forEach(names.claim);
    return (
      cls: '${context.prefix}${DartIdentifier.pascal([segment])}Modes',
      getter: DartIdentifier.camel([context.prefix, segment]),
      fields: [
        for (final t in c.tokens)
          if (TokenDartTypes.of[t.type] case final type?)
            (
              name: names.claim(DartIdentifier.camel(t.path)),
              token: t,
              type: type,
            ),
      ],
      modes: {
        for (final m in c.modes) m: names.claim(DartIdentifier.camel([m])),
      },
      sizes: ModeBreakpoints.of(c.modes),
    );
  }
}
