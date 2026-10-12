import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/token_index.dart';
import 'package:figmine/src/codegen/modes/modes_plan.dart';
import 'package:figmine/src/codegen/modes/size_class.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Writes the static members of a modes class and its context getter.
abstract final class ModesMembers {
  /// An enum value per mode, with the tokens of that mode.
  static List<String> values(ModesPlan p, TokenIndex index, TokenCollection c) {
    final last = p.modes.keys.last;
    return [
      for (final MapEntry(key: mode, value: name) in p.modes.entries) ...[
        '  /// Figma mode `$mode`.',
        '  $name(',
        '    mode: ${DartSource.string(mode)},',
        for (final f in p.fields)
          if (index.find(c.name, f.token.name, mode) case final a?)
            '    ${f.name}: ${a.className}.${a.member},',
        _close(mode == last),
      ],
    ];
  }

  static String _close(bool last) => last ? '  );' : '  ),';

  /// The map of all modes, the lookup by name, and for breakpoints the
  /// lookup by window width with its context getter.
  static List<String> lines(ModesPlan p) {
    final first = p.modes.values.first;
    final all = [
      for (final e in p.modes.entries)
        '${DartSource.string(e.key)}: ${e.value}',
    ];
    return [
      '',
      '  /// Every mode, by its Figma name.',
      '  static const Map<String, ${p.cls}> all = {${all.join(', ')}};',
      '',
      '  /// The mode called [name], or the first mode.',
      '  static ${p.cls} byMode(String name) => all[name] ?? $first;',
      ...?_of(p),
      '}',
    ];
  }

  static List<String>? _of(ModesPlan p) {
    final sizes = p.sizes;
    if (sizes == null) return null;
    String at(SizeClass s) => p.modes[sizes[s]]!;
    return [
      '',
      '  /// The mode for a window [width], by Material window size class:',
      '  /// compact below 600, medium below 840, expanded from there.',
      '  static ${p.cls} of(double width) {',
      '    if (width < 600) return ${at(SizeClass.compact)};',
      '    if (width < 840) return ${at(SizeClass.medium)};',
      '    return ${at(SizeClass.expanded)};',
      '  }',
    ];
  }

  /// The extension with the context getter of breakpoints, or null.
  static List<String>? context(ModesPlan p) {
    if (p.sizes == null) return null;
    return [
      '/// The [${p.cls}] for the width of the current window.',
      'extension ${p.cls}Context on BuildContext {',
      '  /// The mode for the current window width.',
      '  ${p.cls} get ${p.getter} =>',
      '      ${p.cls}.of(MediaQuery.sizeOf(this).width);',
      '}',
    ];
  }
}
