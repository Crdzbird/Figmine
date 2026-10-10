/// What a hard coded value in app code stands for.
enum LiteralKind {
  /// A color, such as `Color(0xFF2C2C2C)`.
  color,

  /// A spacing or size, such as the 16 of `EdgeInsets.all(16)`.
  spacing,

  /// A corner radius, such as the 8 of `BorderRadius.circular(8)`.
  radius,
}
