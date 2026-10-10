import 'package:figmine/src/codegen/codegen_context.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/doc_comment.dart';
import 'package:figmine/src/codegen/typography_roles.dart';
import 'package:figmine/src/config/typography_config.dart';
import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';
import 'package:figmine/src/tokens/text_style_token.dart';

/// Writes the text styles and the TextTheme built from them.
abstract final class TypographyWriter {
  /// Returns the library source for [styles].
  static String write(
    CodegenContext context,
    List<TextStyleToken> styles,
    TypographyConfig config,
  ) {
    final names = UniqueNamer()..claim('textTheme');
    final fields = {
      for (final style in styles)
        style: names.claim(DartIdentifier.camel(style.path)),
    };
    final buffer =
        StringBuffer(context.header(imports: [context.materialImport]))
          ..writeln()
          ..write(
            DocComment.render([
              'Text styles from Figma, and a [TextTheme] of them.',
            ]),
          )
          ..writeln('abstract final class ${context.typographyClass} {');
    for (final entry in fields.entries) {
      final style = entry.key;
      buffer
        ..write(
          DocComment.render([
            DocComment.escape(style.description),
            'Figma text style `${style.name}`.',
          ], indent: 2),
        )
        ..writeln(
          '  static const TextStyle ${entry.value} = '
          '${DartSource.call('TextStyle', _args(style))};',
        )
        ..writeln();
    }
    final roles = TypographyRoles.match(styles, config);
    final args = [
      for (final role in roles.entries) '${role.key}: ${fields[role.value]}',
    ];
    return (buffer
          ..writeln(
            '  /// TextTheme with the styles named after Material roles.',
          )
          ..writeln(
            '  static const TextTheme textTheme = '
            '${DartSource.call('TextTheme', args)};',
          )
          ..writeln('}'))
        .toString();
  }

  static List<String> _args(TextStyleToken style) {
    final height = style.height;
    final spacing = style.letterSpacing;
    return [
      'fontFamily: ${DartSource.string(style.fontFamily)}',
      'fontSize: ${DartSource.number(style.fontSize)}',
      'fontWeight: FontWeight.w${style.fontWeight}',
      if (height != null) 'height: ${_rounded(height, 4)}',
      if (spacing != null) 'letterSpacing: ${_rounded(spacing, 2)}',
      if (style.italic) 'fontStyle: FontStyle.italic',
      if (style.decoration case final decoration?)
        'decoration: TextDecoration.$decoration',
    ];
  }

  static String _rounded(double value, int digits) =>
      DartSource.number(double.parse(value.toStringAsFixed(digits)));
}
