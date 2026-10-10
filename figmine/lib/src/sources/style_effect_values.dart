import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';

/// Reads shadows and gradients from Figma style nodes.
abstract final class StyleEffectValues {
  /// The visible shadows of an effect style [node], or null.
  static ShadowValue? shadow(Map<String, Object?> node) {
    final layers = <ShadowLayer>[
      for (final e in Json.list(node['effects']).map(Json.map))
        if (e['visible'] != false && '${e['type']}'.endsWith('_SHADOW'))
          if (ColorValue.tryParse(e['color']) case final color?)
            (
              color: color,
              x: _num(Json.map(e['offset'])['x']),
              y: _num(Json.map(e['offset'])['y']),
              blur: _num(e['radius']),
              spread: _num(e['spread']),
              inner: e['type'] == 'INNER_SHADOW',
            ),
    ];
    return layers.isEmpty ? null : ShadowValue(layers);
  }

  /// The first visible gradient fill of a style [node], or null.
  static GradientValue? gradient(Map<String, Object?> node) {
    for (final fill in Json.list(node['fills']).map(Json.map)) {
      final type = '${fill['type']}';
      if (!type.startsWith('GRADIENT_') || fill['visible'] == false) continue;
      return GradientValue(
        kind: type.substring('GRADIENT_'.length).toLowerCase(),
        stops: [
          for (final s in Json.list(fill['gradientStops']).map(Json.map))
            if (ColorValue.tryParse(s['color']) case final color?)
              (color: color, position: _num(s['position'])),
        ],
        handles: [
          for (final h in Json.list(
            fill['gradientHandlePositions'],
          ).map(Json.map))
            (_num(h['x']), _num(h['y'])),
        ],
      );
    }
    return null;
  }

  static double _num(Object? value) => value is num ? value.toDouble() : 0;
}
