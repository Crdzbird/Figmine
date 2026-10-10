import 'package:figmine/src/audit/contrast_finding.dart';
import 'package:figmine/src/codegen/scheme_fields.dart';
import 'package:figmine/src/inference/color_math.dart';

/// Checks the color scheme against WCAG 2.2 contrast minimums.
abstract final class ContrastAudit {
  /// Text on its container needs 4.5:1, the AA minimum for body text.
  static const double text = 4.5;

  /// Outlines need 3:1 against the surface, the non-text minimum.
  static const double nonText = 3;

  static const List<(String, String, double)> _material = [
    ('onSurface', 'surface', text),
    ('onSurfaceVariant', 'surface', text),
    ('onSurface', 'surfaceContainerHighest', text),
    ('onInverseSurface', 'inverseSurface', text),
    ('outline', 'surface', nonText),
  ];

  /// Every pair checked in [fields]: Material pairs, every `onX` with its
  /// `X`, in light and dark mode. Disabled states are exempt, as in WCAG.
  static List<(String, String, double)> pairs(List<SchemeField> fields) {
    final names = {for (final f in fields) f.name};
    return {
      ..._material,
      for (final name in names)
        if (name.startsWith('on') &&
            name.length > 2 &&
            !name.contains('Disabled'))
          if (_container(name) case final base? when names.contains(base))
            (name, base, text),
    }.toList();
  }

  /// The pairs of [fields] that fail their target.
  static List<ContrastFinding> run(List<SchemeField> fields) {
    final byName = {for (final f in fields) f.name: f};
    return [
      for (final (fg, bg, required) in pairs(fields))
        if (byName[fg] case final f?)
          if (byName[bg] case final b?)
            for (final mode in const ['light', 'dark'])
              ?_check(f, b, mode, required),
    ];
  }

  static String? _container(String name) =>
      '${name[2].toLowerCase()}${name.substring(3)}';

  static ContrastFinding? _check(
    SchemeField fg,
    SchemeField bg,
    String mode,
    double required,
  ) {
    final f = mode == 'light' ? fg.lightArgb : fg.darkArgb;
    final b = mode == 'light' ? bg.lightArgb : bg.darkArgb;
    if (ColorMath.alpha(b) < 1) return null;
    final ratio = ColorMath.contrast(f, b);
    if (ratio >= required) return null;
    return (
      foreground: fg.name,
      background: bg.name,
      mode: mode,
      ratio: ratio,
      required: required,
      foregroundArgb: f,
      backgroundArgb: b,
    );
  }
}
