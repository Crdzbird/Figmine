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
  gradient,

  /// A flag, from a `BOOLEAN` variable.
  boolean,

  /// A duration, from a number named for a duration or a DTCG `duration`.
  duration,

  /// An easing curve, from a `cubic-bezier()` string or a DTCG
  /// `cubicBezier`.
  curve,

  /// A font weight, from a number named for a font weight or a DTCG
  /// `fontWeight`.
  fontWeight;

  /// Maps a Figma `resolvedType`, or returns null when unsupported.
  static TokenType? fromFigma(Object? resolvedType) => switch (resolvedType) {
    'COLOR' => color,
    'FLOAT' => number,
    'STRING' => string,
    'BOOLEAN' => boolean,
    _ => null,
  };
}
