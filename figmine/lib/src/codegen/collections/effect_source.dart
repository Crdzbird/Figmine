import 'dart:math' as math;

import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';

/// Renders shadows and gradients as Dart constants.
abstract final class EffectSource {
  /// A `List<BoxShadow>` literal. Inner shadows use `BlurStyle.inner`.
  static String shadows(ShadowValue value) {
    final layers = value.layers.map((l) {
      final args = [
        'color: ${DartSource.color(l.color.hex)}',
        if (l.x != 0 || l.y != 0) 'offset: Offset(${_n(l.x)}, ${_n(l.y)})',
        if (l.blur != 0) 'blurRadius: ${_n(l.blur)}',
        if (l.spread != 0) 'spreadRadius: ${_n(l.spread)}',
        if (l.inner) 'blurStyle: BlurStyle.inner',
      ];
      return 'BoxShadow(${args.join(', ')})';
    });
    return '[${layers.join(', ')}]';
  }

  /// A `LinearGradient`, `RadialGradient` or `SweepGradient` literal.
  static String gradient(GradientValue value) {
    final colors = value.stops.map((s) => DartSource.color(s.color.hex));
    final stops = value.stops.map((s) => _n(s.position));
    final list = 'colors: [${colors.join(', ')}], stops: [${stops.join(', ')}]';
    final start = _alignment(value.handles.firstOrNull ?? (0, 0.5));
    final end = _alignment(value.handles.elementAtOrNull(1) ?? (1, 0.5));
    return switch (value.kind) {
      'radial' || 'diamond' =>
        'RadialGradient(center: $start, radius: ${_n(_radius(value))}, $list)',
      'angular' => 'SweepGradient(center: $start, $list)',
      _ => 'LinearGradient(begin: $start, end: $end, $list)',
    };
  }

  static final Map<(double, double), String> _named = {
    (-1, -1): 'topLeft',
    (0, -1): 'topCenter',
    (1, -1): 'topRight',
    (-1, 0): 'centerLeft',
    (0, 0): 'center',
    (1, 0): 'centerRight',
    (-1, 1): 'bottomLeft',
    (0, 1): 'bottomCenter',
    (1, 1): 'bottomRight',
  };

  static String _alignment((double, double) p) {
    final x = double.parse((p.$1 * 2 - 1).toStringAsFixed(3));
    final y = double.parse((p.$2 * 2 - 1).toStringAsFixed(3));
    final named = _named[(x == 0 ? 0.0 : x, y == 0 ? 0.0 : y)];
    if (named != null) return 'Alignment.$named';
    return 'Alignment(${_n(x)}, ${_n(y)})';
  }

  static double _radius(GradientValue v) {
    final a = v.handles.firstOrNull ?? (0.5, 0.5);
    final b = v.handles.elementAtOrNull(1) ?? (1, 0.5);
    return math.sqrt(math.pow(b.$1 - a.$1, 2) + math.pow(b.$2 - a.$2, 2));
  }

  static String _n(double value) =>
      DartSource.number(double.parse(value.toStringAsFixed(3)));
}
