import 'package:figmine/src/audit/contrast_finding.dart';
import 'package:figmine/src/audit/contrast_fix.dart';
import 'package:figmine/src/codegen/material_roles.dart';
import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/inference/color_math.dart';

/// Turns contrast fixes into `figmine.yaml` settings.
abstract final class FixSnippet {
  /// The `color_scheme` settings that apply [fixes], one per finding of
  /// [findings], to the scheme [fields]: a role mapped to the token when
  /// the token passes in both modes, otherwise an override that keeps the
  /// passing mode. Empty when there is nothing to apply.
  static String yaml(
    List<ContrastFinding> findings,
    List<ContrastFix?> fixes,
    List<SchemeField> fields,
  ) {
    final by = {for (final f in fields) f.name: f};
    final roles = <String, String>{};
    final overrides = <String, Map<String, int>>{};
    for (var i = 0; i < findings.length; i++) {
      final fix = fixes[i];
      final field = by[findings[i].foreground];
      if (fix == null || field == null) continue;
      final token = fix.token;
      final role = MaterialRoles.colorScheme.contains(fix.field);
      if (token != null && fix.bothModes && role) {
        roles[fix.field] = token;
        continue;
      }
      if (roles.containsKey(fix.field)) continue;
      final colors = overrides[fix.field] ??= {
        'light': field.lightArgb,
        'dark': field.darkArgb,
      };
      colors[findings[i].mode] = fix.argb;
    }
    if (roles.isEmpty && overrides.isEmpty) return '';
    return [
      'color_scheme:',
      if (roles.isNotEmpty) '  roles:',
      for (final e in roles.entries) '    ${e.key}: "${e.value}"',
      if (overrides.isNotEmpty) '  overrides:',
      for (final e in overrides.entries)
        if (!roles.containsKey(e.key)) _override(e.key, e.value),
    ].join('\n');
  }

  static String _override(String field, Map<String, int> colors) {
    final light = ColorMath.hex(colors['light']!);
    final dark = ColorMath.hex(colors['dark']!);
    return '    $field: {light: "$light", dark: "$dark"}';
  }
}
