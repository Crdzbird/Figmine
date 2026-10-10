/// How app code uses a hard coded color.
enum LiteralUsage {
  /// Fills a shape, such as `BoxDecoration(color: ...)`.
  background('background|fill|surface|bg|container'),

  /// Colors text, such as `TextStyle(color: ...)`.
  text('text|foreground|content'),

  /// Colors icons, such as `Icon(color: ...)`.
  icon('icon'),

  /// Draws a line, such as `Divider(color: ...)`.
  outline('border|stroke|outline|divider');

  new(this.tokens);

  /// Pattern of token names meant for this use.
  final String tokens;

  static final RegExp _text = RegExp(r'^(TextStyle|DefaultTextStyle|Text)$');

  static final RegExp _icon = RegExp(r'^(Icon|IconThemeData|ImageIcon)$');

  static final RegExp _line = RegExp(
    r'^(Divider|VerticalDivider|BorderSide|Border\.all|Border)$',
  );

  /// The use of a color passed to [owner], the constructor whose argument
  /// list holds it, as the named argument [property].
  static LiteralUsage of(String? owner, String? property) {
    final key = property?.toLowerCase() ?? '';
    if (_icon.hasMatch(owner ?? '') || key.contains('icon')) return icon;
    if (_text.hasMatch(owner ?? '') || key.contains('foreground')) {
      return text;
    }
    if (_line.hasMatch(owner ?? '') || key.contains('border')) return outline;
    return background;
  }

  /// Whether the scheme field [role] is meant for this use.
  bool fitsRole(String role) => switch (this) {
    background => !role.startsWith('on') && !role.startsWith('outline'),
    text || icon => role.startsWith('on'),
    outline => role.startsWith('outline') || role.endsWith('Outline'),
  };
}
