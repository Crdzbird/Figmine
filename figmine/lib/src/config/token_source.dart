/// Where tokens are read from.
enum TokenSource {
  /// Token files when configured, otherwise Variables, then color styles.
  auto,

  /// Figma Variables. Needs an Enterprise plan.
  variables,

  /// Color styles, available on every plan.
  styles,

  /// Design token JSON files, such as a figmine or Figma variables export.
  file;

  /// Parses a config value, defaulting to [auto].
  static TokenSource parse(String? value) =>
      values.firstWhere((source) => source.name == value, orElse: () => auto);
}
