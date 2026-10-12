import 'package:figmine/src/inference/components/button_style_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';

/// The styles of buttons figmine themes.
enum ButtonVariant {
  /// Filled buttons, with a fill.
  filled(r'\bprimary\b'),

  /// Outlined buttons, with a border and a light or no fill.
  outlined(r'\b(outline|outlined|secondary|neutral|stroke)\b'),

  /// Text buttons, with a label and neither fill nor border.
  text(r'\b(text|ghost|link|subtle|tertiary|plain)\b');

  new(this.hint);

  /// Pattern of names that suggest this style.
  final String hint;

  /// Whether [s] has this style.
  bool matches(ComponentSample s) => switch (this) {
    filled => ButtonStyleKind.isFilled(s),
    outlined => ButtonStyleKind.isOutlined(s),
    text => ButtonStyleKind.isText(s),
  };
}
