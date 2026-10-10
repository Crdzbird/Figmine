/// How a layer uses a paint.
enum PaintUsage {
  /// The fill of a shape or frame.
  background,

  /// The fill of a text layer.
  text,

  /// A stroke.
  stroke;

  /// The usage that best describes a ColorScheme [role].
  static PaintUsage of(String role) {
    if (role.startsWith('outline')) return stroke;
    if (role.startsWith('on')) return text;
    return background;
  }
}
