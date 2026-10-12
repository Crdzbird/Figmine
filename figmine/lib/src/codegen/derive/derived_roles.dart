import 'package:figmine/src/codegen/derive/seed_scheme.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/value_expressions.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/variables/collection_modes.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// ColorScheme roles derived from the seed, for roles Figma lacks.
final class DerivedRoles {
  /// Derives light and dark roles from the [seed] token. Dark roles keep
  /// the light seed's chroma, as a pale dark primary cannot hold it.
  factory(ColorCandidate? seed, TokensConfig config) {
    final modes = seed == null
        ? null
        : CollectionModes.pick(seed.collection.modes, config);
    final light = _argb(seed?.token.values[modes?.light]?.value);
    final dark = _argb(seed?.token.values[modes?.dark]?.value) ?? light;
    return DerivedRoles._(
      light: SeedScheme.derive(light ?? SeedScheme.baseline, dark: false),
      dark: SeedScheme.derive(
        dark ?? SeedScheme.baseline,
        dark: true,
        chroma: light == null ? 0 : Hct.fromInt(light).chroma,
      ),
      seedName: seed == null ? 'the Material baseline' : seed.token.name,
    );
  }

  const new _({
    required this.light,
    required this.dark,
    required this.seedName,
  });

  /// Light roles as ARGB.
  final Map<String, int> light;

  /// Dark roles as ARGB.
  final Map<String, int> dark;

  /// Name of the seed, for documentation.
  final String seedName;

  /// Literal of [role] in light or dark mode.
  ValueExpression literal(String role, {required bool dark}) {
    final argb = (dark ? this.dark : light)[role]!;
    final hex = '0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return (code: DartSource.color(hex), file: null);
  }

  static int? _argb(Object? value) => value is ColorValue ? value.argb : null;
}
