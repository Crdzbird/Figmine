import 'package:figmine/src/codegen/derive/derived_values.dart';
import 'package:figmine/src/codegen/derive/seed_scheme.dart';
import 'package:figmine/src/codegen/scheme/scheme_field_builders.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Builds scheme fields for roles Figma lacks.
abstract final class DerivedFields {
  /// The Material [role] Figma lacks, derived from the seed and moved onto
  /// the design's role scale when one is close.
  static SchemeField role(String name, String role, DerivedValues values) {
    final light = values.of(role, dark: false);
    final dark = values.of(role, dark: true);
    return (
      name: name,
      doc:
          'Material role `$role`, derived from '
          '`${values.derived.seedName}`.${steps(light, dark)}',
      light: light.value,
      dark: dark.value,
      lightArgb: light.argb,
      darkArgb: dark.argb,
    );
  }

  /// `<name>Container` and `on<Name>Container` for the feedback role
  /// [name] when the design has its scale: the steps nearest the tones of
  /// the error containers. Roles [taken] elsewhere are skipped.
  static List<SchemeField> containers(
    String name,
    DerivedValues values,
    bool Function(String role) taken,
  ) {
    if (!values.ramps.containsKey(name)) return const [];
    final upper = '${name[0].toUpperCase()}${name.substring(1)}';
    return [
      for (final (role, like) in [
        ('${name}Container', 'errorContainer'),
        ('on${upper}Container', 'onErrorContainer'),
      ])
        if (!taken(role)) _like(role, like, values),
    ];
  }

  static SchemeField _like(String role, String like, DerivedValues values) {
    final light = values.near(role, values.derived.light[like]!);
    final dark = values.near(role, values.derived.dark[like]!);
    return (
      name: role,
      doc:
          'Like `$like`, on the `${role.replaceAll('Container', '')}` '
          'scale.${steps(light, dark)}',
      light: light.value,
      dark: dark.value,
      lightArgb: light.argb,
      darkArgb: dark.argb,
    );
  }

  /// Tells where [light] and [dark] come from on the role scale, when they
  /// do.
  static String steps(DerivedValue? light, DerivedValue dark) {
    final notes = [
      if (light?.note case final note?) 'Light: $note.',
      if (dark.note case final note?) 'Dark: $note.',
    ];
    if (notes.isEmpty) return '';
    return ' Moved onto the role scale by tone. ${notes.join(' ')}';
  }

  /// The dark value of [role] set by hand as the single color [light]: its
  /// hue and chroma at the tone the role takes in a dark scheme seeded
  /// with [light] itself.
  static DerivedValue dark(String role, int light, DerivedValues values) {
    final own = SeedScheme.derive(light, dark: true)[role];
    final tone = Hct.fromInt(own ?? values.derived.dark[role]!).tone;
    final hct = Hct.fromInt(light);
    return values.near(role, Hct.from(hct.hue, hct.chroma, tone).toInt());
  }
}
