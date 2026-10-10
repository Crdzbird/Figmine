/// A foreground and background pair below its WCAG contrast target.
typedef ContrastFinding = ({
  String foreground,
  String background,
  String mode,
  double ratio,
  double required,
  int foregroundArgb,
  int backgroundArgb,
});
