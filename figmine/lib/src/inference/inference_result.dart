import 'package:figmine/src/inference/screen_evidence.dart';
import 'package:figmine/src/tokens/component_metric.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Tokens recognized in the designed screens.
final class InferenceResult {
  /// Creates a result.
  const factory({
    required int frames,
    int darkScreens,
    TokenCollection? colors,
    TokenCollection? layout,
    List<TextStyleToken> textStyles,
    Map<String, ComponentMetric> components,
    ScreenEvidence evidence,
  }) = InferenceResult._;

  const new _({
    required this.frames,
    this.darkScreens = 0,
    this.colors,
    this.layout,
    this.textStyles = const [],
    this.components = const {},
    this.evidence = noEvidence,
  });

  /// Number of analyzed frames.
  final int frames;

  /// Number of those frames in dark mode.
  final int darkScreens;

  /// Color roles in light and dark mode, or null without colors.
  final TokenCollection? colors;

  /// Spacing and radius scales, or null when none are used.
  final TokenCollection? layout;

  /// Text styles mapped onto TextTheme roles.
  final List<TextStyleToken> textStyles;

  /// Button, card, input, chip and app bar dimensions.
  final Map<String, ComponentMetric> components;

  /// What the screens tell about colors: bound variables, color use and
  /// component state colors.
  final ScreenEvidence evidence;
}
