import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/fixed_file.dart';

/// Writes the BuildContext extension that exposes the color scheme.
abstract final class ContextWriter {
  /// Returns the library source.
  static String write(CodegenContext context) {
    final scheme = context.colorSchemeClass;
    final buffer =
        StringBuffer(
            context.header(
              imports: [
                context.materialImport,
                context.uriOf(FixedFile.colorScheme),
              ],
            ),
          )
          ..writeln()
          ..writeln(
            '/// Shortcuts to the design system of the nearest [Theme].',
          )
          ..writeln('extension ${context.contextExtension} on BuildContext {')
          ..writeln('  /// The color scheme of the current theme.')
          ..writeln('  ///')
          ..writeln('  /// Falls back to the generated light or dark scheme,')
          ..writeln('  /// matching the theme brightness, when none is set.')
          ..writeln('  $scheme get ${context.colorSchemeGetter} {')
          ..writeln('    final theme = Theme.of(this);')
          ..writeln('    final fallback = theme.brightness == Brightness.dark')
          ..writeln('        ? $scheme.dark')
          ..writeln('        : $scheme.light;')
          ..writeln('    return theme.extension<$scheme>() ?? fallback;')
          ..writeln('  }')
          ..writeln('}');
    return buffer.toString();
  }
}
