/// The kind of value a design token holds.
enum TokenType {
  /// A color, from a `COLOR` variable or a fill style.
  color,

  /// A number, from a `FLOAT` variable, such as a spacing or radius.
  number,

  /// A string, from a `STRING` variable, such as a font family.
  string,

  /// Shadows, from an effect style.
  shadow,

  /// A gradient, from a fill style.
  gradient;

  /// Maps a Figma `resolvedType`, or returns null when unsupported.
  static TokenType? fromFigma(Object? resolvedType) => switch (resolvedType) {
    'COLOR' => color,
    'FLOAT' => number,
    'STRING' => string,
    _ => null,
  };
}
