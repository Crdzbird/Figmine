import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/dtcg/dtcg_values.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';

/// Parses DTCG shadow and gradient values.
abstract final class DtcgEffects {
  /// A DTCG shadow: one `{color, offsetX, offsetY, blur, spread, inset}`
  /// object, or a list of them.
  static ShadowValue? shadow(Object? raw) {
    final list = raw is List ? raw : [raw];
    final layers = <ShadowLayer>[];
    for (final item in list.map(Json.map)) {
      final color = DtcgValues.color(item['color']);
      if (color == null) return null;
      double n(String key) => DtcgValues.number(item[key]) ?? 0;
      layers.add((
        color: color,
        x: n('offsetX'),
        y: n('offsetY'),
        blur: n('blur'),
        spread: n('spread'),
        inner: item['inset'] == true,
      ));
    }
    return layers.isEmpty ? null : ShadowValue(layers);
  }

  /// A DTCG gradient: a list of `{color, position}` stops, drawn left to
  /// right, or `{kind, stops, handles}` as the figmine exporter writes it.
  static GradientValue? gradient(Object? raw) {
    final map = raw is Map ? Json.map(raw) : const <String, Object?>{};
    final stops = <GradientStop>[];
    for (final stop in Json.list(
      raw is List ? raw : map['stops'],
    ).map(Json.map)) {
      final color = DtcgValues.color(stop['color']);
      if (color == null) return null;
      stops.add((
        color: color,
        position: DtcgValues.number(stop['position']) ?? 0,
      ));
    }
    if (stops.length < 2) return null;
    return GradientValue(
      kind: '${map['kind'] ?? 'linear'}',
      stops: stops,
      handles: [
        for (final h in Json.list(map['handles']).map(Json.map))
          (DtcgValues.number(h['x']) ?? 0, DtcgValues.number(h['y']) ?? 0),
      ],
    );
  }
}
