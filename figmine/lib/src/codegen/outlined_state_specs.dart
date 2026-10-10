import 'package:figmine/src/codegen/state_field_specs.dart';

/// The state fields of outlined buttons. Their default fill is
/// transparent, as in Material, with state layers of the label color.
abstract final class OutlinedStateSpecs {
  static const String _k = 'outlinedButton';

  static StateSpec _s(
    String name,
    String key,
    String base, [
    String? overlay,
    double opacity = 0,
  ]) => (
    name: name,
    key: '$_k.$key',
    base: base,
    overlay: overlay,
    opacity: opacity,
  );

  /// Every field, resting colors first.
  static final List<StateSpec> all = [
    _s(_k, 'enabled.fill', 'transparent'),
    _s('onOutlinedButton', 'enabled.label', 'primary'),
    _s('outlinedButtonOutline', 'enabled.stroke', 'outline'),
    _s(
      'outlinedButtonHovered',
      'hovered.fill',
      'transparent',
      'onOutlinedButton',
      0.08,
    ),
    _s('onOutlinedButtonHovered', 'hovered.label', 'onOutlinedButton'),
    _s(
      'outlinedButtonHoveredOutline',
      'hovered.stroke',
      'outlinedButtonOutline',
    ),
    _s(
      'outlinedButtonPressed',
      'pressed.fill',
      'transparent',
      'onOutlinedButton',
      0.1,
    ),
    _s('onOutlinedButtonPressed', 'pressed.label', 'onOutlinedButton'),
    _s(
      'outlinedButtonPressedOutline',
      'pressed.stroke',
      'outlinedButtonOutline',
    ),
    _s(
      'outlinedButtonFocused',
      'focused.fill',
      'transparent',
      'onOutlinedButton',
      0.1,
    ),
    _s('onOutlinedButtonFocused', 'focused.label', 'onOutlinedButton'),
    _s(
      'outlinedButtonFocusedOutline',
      'focused.stroke',
      'outlinedButtonOutline',
    ),
    _s('outlinedButtonDisabled', 'disabled.fill', 'transparent'),
    _s(
      'onOutlinedButtonDisabled',
      'disabled.label',
      'surface',
      'onSurface',
      0.38,
    ),
    _s(
      'outlinedButtonDisabledOutline',
      'disabled.stroke',
      'surface',
      'onSurface',
      0.12,
    ),
  ];
}
