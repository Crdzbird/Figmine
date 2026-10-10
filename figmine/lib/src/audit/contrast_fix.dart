/// A color that brings a failing foreground to its contrast target: a
/// Figma token when one fits, given by its collection and name, or a
/// color of the same hue at a new tone.
typedef ContrastFix = ({
  String field,
  int argb,
  double ratio,
  String? token,
  String? collection,
  bool bothModes,
});
