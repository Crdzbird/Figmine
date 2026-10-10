import 'package:figmine/src/tokens/color_value.dart';

/// A color stop of a gradient, at a position from 0 to 1.
typedef GradientStop = ({ColorValue color, double position});

/// A Figma gradient paint: its kind, its stops, and the handles that place
/// it, from 0 to 1 across the shape.
final class GradientValue {
  /// Creates a gradient.
  const factory({
    required String kind,
    required List<GradientStop> stops,
    required List<(double, double)> handles,
  }) = GradientValue._;

  const new _({required this.kind, required this.stops, required this.handles});

  /// `linear`, `radial`, `angular` or `diamond`.
  final String kind;

  /// The color stops, in order.
  final List<GradientStop> stops;

  /// The start, end and width handles.
  final List<(double, double)> handles;
}
