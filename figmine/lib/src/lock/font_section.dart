import 'package:figmine/src/tokens/text_style_token.dart';

/// A font family the text styles use that the app does not bundle.
typedef MissingFont = ({String family, int styles});

/// Finds font families the app does not bundle, and reports them.
abstract final class FontSection {
  static final RegExp _platform = RegExp(
    r'^(roboto|sf pro.*|\.sf.*|san francisco|system-ui|-apple-system)$',
    caseSensitive: false,
  );

  /// Families of [styles] that are not in [bundled] nor a platform font,
  /// with how many styles use each, most used first.
  static List<MissingFont> missing(
    List<TextStyleToken> styles,
    Set<String> bundled,
  ) {
    final known = {for (final f in bundled) f.toLowerCase()};
    final counts = <String, int>{};
    for (final style in styles) {
      final family = style.fontFamily.trim();
      if (family.isEmpty || _platform.hasMatch(family)) continue;
      if (known.contains(family.toLowerCase())) continue;
      counts[family] = (counts[family] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value - a.value);
    return [for (final e in sorted) (family: e.key, styles: e.value)];
  }

  /// One terminal line per missing family.
  static List<String> log(List<MissingFont> fonts) => fonts.map(_line).toList();

  static String _line(MissingFont f) =>
      'Font ${f.family} is used by ${_styles(f.styles)} but not bundled, so '
      'Flutter shows the platform font. Add it under flutter.fonts in '
      'pubspec.yaml.';

  /// Writes the Markdown section into [buffer]. Nothing when all fonts
  /// are bundled.
  static void write(StringBuffer buffer, List<MissingFont> fonts) {
    if (fonts.isEmpty) return;
    buffer
      ..writeln('### Fonts')
      ..writeln()
      ..writeln(
        'These fonts are not bundled, so Flutter shows the platform font. '
        'Add each under `flutter.fonts` in `pubspec.yaml`:',
      )
      ..writeln();
    for (final f in fonts) {
      buffer.writeln('- `${f.family}`, in ${_styles(f.styles)}');
    }
    buffer.writeln();
  }

  static String _styles(int n) => n == 1 ? '1 text style' : '$n text styles';
}
