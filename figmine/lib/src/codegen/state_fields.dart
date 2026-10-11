import 'package:figmine/src/codegen/scheme_field_builders.dart';
import 'package:figmine/src/codegen/scheme_matcher.dart';
import 'package:figmine/src/codegen/state_dark.dart';
import 'package:figmine/src/codegen/state_extrapolation.dart';
import 'package:figmine/src/codegen/state_fallback.dart';
import 'package:figmine/src/codegen/state_field_specs.dart';
import 'package:figmine/src/codegen/state_readable.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/sources/collection_modes.dart';

/// Builds the component state fields of the color scheme.
abstract final class StateFields {
  /// The state fields not already among [scheme]: the variable bound in
  /// the Figma variant, the scheme field with the same color, the variant
  /// color itself, or the Material default.
  static List<SchemeField> resolve(
    List<SchemeField> scheme,
    SchemeMatcher matcher,
    TokenIndex index,
    TokensConfig tokens,
  ) {
    final by = {for (final f in scheme) f.name: f};
    final result = <SchemeField>[];
    for (final spec in StateFieldSpecs.all) {
      if (by.containsKey(spec.name)) continue;
      final field = _field(spec, by, matcher, index, tokens);
      by[spec.name] = field;
      result.add(field);
    }
    return result;
  }

  static SchemeField _field(
    StateSpec spec,
    Map<String, SchemeField> by,
    SchemeMatcher matcher,
    TokenIndex index,
    TokensConfig tokens,
  ) {
    final paint = matcher.evidence.componentColors[spec.key];
    final kind = spec.key.split('.').first;
    final hovered = matcher.evidence.componentColors['$kind.hovered.fill'];
    final follows =
        spec.key.endsWith('pressed.fill') || spec.key.endsWith('focused.fill');
    if (paint == null && follows && hovered != null) {
      final field = by['${kind}Hovered'];
      final followed = field == null
          ? null
          : StateExtrapolation.follow(spec, field, by);
      if (followed != null) return followed;
    }
    if (paint == null) return StateFallback.material(spec, by);
    final variant = '`${spec.key.split('.')[1]}` variant';
    final token = matcher.all
        .where((c) => c.token.variableId == paint.variable)
        .firstOrNull;
    if (paint.variable != null && token != null) {
      final field = SchemeFieldBuilders.field(spec.name, token, index, tokens);
      final modes = CollectionModes.pick(token.collection.modes, tokens);
      if (modes.light != modes.dark) return field;
      return StateDark.apply(
        spec,
        field,
        by,
        '${field.doc} Bound in the $variant.',
      );
    }
    final rest = by[StateFieldSpecs.rest(spec).$1];
    final same = [by[spec.base], ...by.values].nonNulls
        .where((f) => f.lightArgb == paint.argb && _sameRole(spec, f))
        .where((f) => StateReadable.keeps(spec, f, f.darkArgb, rest))
        .firstOrNull;
    if (same != null) {
      return StateFallback.copy(spec.name, same, 'Same as `${same.name}`.');
    }
    final light = StateFallback.literal(paint.argb);
    final field = (
      name: spec.name,
      doc: 'The $variant in Figma.',
      light: light,
      dark: light,
      lightArgb: paint.argb,
      darkArgb: paint.argb,
    );
    return StateDark.apply(spec, field, by, field.doc);
  }

  /// Whether [f] plays the part [spec] reads: fills copy fills and labels
  /// copy `on` colors, so a white fill never takes the dark value of white
  /// text.
  static bool _sameRole(StateSpec spec, SchemeField f) {
    final on = RegExp('^on[A-Z]').hasMatch(f.name);
    if (spec.key.endsWith('.fill')) return !on;
    if (spec.key.endsWith('.label')) return on;
    return true;
  }
}
