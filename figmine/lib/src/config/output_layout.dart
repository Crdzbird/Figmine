/// How generated token files are organized into folders.
enum OutputLayout {
  /// By what a developer looks for: color, typography, units, components
  /// and icons.
  domain,

  /// Mirroring the Figma collection names, such as `figma/ui/colors`.
  figma;

  /// Parses a config or command line value, defaulting to [domain].
  static OutputLayout parse(String? value) =>
      values.firstWhere((layout) => layout.name == value, orElse: () => domain);
}
