import 'package:figmine/src/tokens/text_style_token.dart';

/// Traits of text styles that matter when picking role styles.
abstract final class TextStyleTraits {
  /// [styles] without repeats: of the styles with the same family, size,
  /// weight and decoration, such as `Body Base` and `Single Line/Body Base`,
  /// only the one with the shortest name stays.
  static List<TextStyleToken> distinct(Iterable<TextStyleToken> styles) {
    final kept = <String, TextStyleToken>{};
    for (final s in styles) {
      final key =
          '${s.fontFamily}|${s.fontSize}|${s.fontWeight}|${s.italic}|'
          '${s.decoration}';
      final previous = kept[key];
      if (previous == null || s.name.length < previous.name.length) {
        kept[key] = s;
      }
    }
    return [
      for (final s in styles)
        if (kept.containsValue(s)) s,
    ];
  }

  static final RegExp _special = RegExp(
    'code|mono|link|emphasis|italic|underline|strike|upper|caps',
  );

  /// Italic, underlined, uppercase, monospace, code and link styles are
  /// variants of a role, not its default, so they rank behind plain styles.
  static double penalty(TextStyleToken style) {
    final name = '${style.name} ${style.fontFamily}'.toLowerCase();
    final special =
        style.italic || style.decoration != null || _special.hasMatch(name);
    return special ? 4 : 0;
  }

  /// Styles whose name has a segment starting with `.` or `_`, which Figma
  /// keeps out of published libraries.
  static bool isPrivate(TextStyleToken style) =>
      style.path.any((p) => p.startsWith('.') || p.startsWith('_'));
}
