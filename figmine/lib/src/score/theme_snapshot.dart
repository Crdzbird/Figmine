/// The font family and size of a text role.
typedef TextFacts = ({String family, double size});

/// The values a theme gives, by name: scheme colors in light and dark
/// mode, component dimensions, and text roles.
typedef ThemeSnapshot = ({
  Map<String, int> light,
  Map<String, int> dark,
  Map<String, double> components,
  Map<String, TextFacts> text,
});
