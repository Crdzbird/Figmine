import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/metric_specs.dart';

/// How a metric is measured: its kind, what it reads from a sample, and
/// whether the median replaces the most common value.
typedef MetricRead = (
  ComponentKind kind,
  double? Function(ComponentSample sample) read,
  bool median,
);

/// What each component metric reads from the samples.
abstract final class MetricReads {
  static double? _radius(ComponentSample s) => s.pill ? 999 : s.radius;

  static double? _height(ComponentSample s) => s.height > 0 ? s.height : null;

  static double? _elevation(ComponentSample s) =>
      s.shadow > 0 ? (s.shadow / 2).clamp(1, 12).roundToDouble() : 0;

  /// What each metric reads, in the order of [MetricSpecs.defaults].
  static final Map<String, MetricRead> all = {
    'buttonRadius': (ComponentKind.button, _radius, false),
    'buttonHeight': (ComponentKind.button, _height, true),
    'buttonPaddingHorizontal': (
      ComponentKind.button,
      (s) => s.paddingHorizontal,
      true,
    ),
    'cardRadius': (ComponentKind.card, _radius, false),
    'cardPadding': (ComponentKind.card, (s) => s.padding, false),
    'cardElevation': (ComponentKind.card, _elevation, false),
    'inputRadius': (ComponentKind.input, _radius, false),
    'inputHeight': (ComponentKind.input, _height, false),
    'chipRadius': (ComponentKind.chip, _radius, false),
    'appBarHeight': (ComponentKind.appBar, _height, false),
    'fabRadius': (ComponentKind.fab, _radius, false),
    'fabSize': (ComponentKind.fab, _height, false),
    'navigationBarHeight': (ComponentKind.navigationBar, _height, false),
    'sheetRadius': (ComponentKind.bottomSheet, _radius, false),
    'dialogRadius': (ComponentKind.dialog, _radius, false),
    'snackbarRadius': (ComponentKind.snackbar, _radius, false),
    'tooltipRadius': (ComponentKind.tooltip, _radius, false),
  };
}
