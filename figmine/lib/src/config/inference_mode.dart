/// When tokens are inferred from the designed screens.
enum InferenceMode {
  /// Colors and typography only when Figma defines none, layout always.
  auto,

  /// Colors, typography and layout always, next to defined tokens.
  always,

  /// Never analyze screens.
  off;

  /// Parses a config value, defaulting to [auto].
  static InferenceMode parse(String? value) =>
      values.firstWhere((mode) => mode.name == value, orElse: () => auto);
}
