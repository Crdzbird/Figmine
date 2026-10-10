import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/naming/token_naming.dart';

/// Writes the class with the asset path of every icon.
abstract final class IconsWriter {
  /// Returns the library source for [icons] stored under [assetDirectory].
  static String write(
    CodegenContext context,
    List<NamedIcon> icons,
    String assetDirectory,
  ) {
    final buffer = StringBuffer(context.header())
      ..writeln()
      ..writeln('/// SVG icons exported from Figma.')
      ..writeln('///')
      ..writeln(
        '/// Render them with `FigmineIcon(${context.iconsClass}.name)`.',
      )
      ..writeln('abstract final class ${context.iconsClass} {');
    for (final icon in icons) {
      final path = DartSource.string('$assetDirectory/${icon.file}');
      buffer
        ..writeln(
          '  /// Figma component ${DartSource.docCode(icon.token.name)}.',
        )
        ..writeln('  static const String ${icon.field} = $path;')
        ..writeln();
    }
    final all = [for (final icon in icons) icon.field].join(', ');
    return (buffer
          ..writeln('  /// Every icon asset path.')
          ..writeln('  static const List<String> values = <String>[$all];')
          ..writeln('}'))
        .toString();
  }
}
