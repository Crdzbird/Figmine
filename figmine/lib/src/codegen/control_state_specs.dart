import 'package:figmine/src/codegen/state_field_specs.dart';

/// The state fields of checkboxes, radios, switches, tabs and text
/// buttons, with the Material defaults of each.
abstract final class ControlStateSpecs {
  static StateSpec _s(
    String name,
    String key,
    String base, [
    String? overlay,
    double opacity = 0,
  ]) => StateFieldSpecs.spec(name, key, base, overlay, opacity);

  /// Every field, resting colors first.
  static final List<StateSpec> all = [
    _s('checkboxSelected', 'checkbox.selected.fill', 'primary'),
    _s('onCheckboxSelected', 'checkbox.selected.mark', 'onPrimary'),
    _s('checkboxOutline', 'checkbox.enabled.stroke', 'onSurfaceVariant'),
    _s('checkboxHoveredOutline', 'checkbox.hovered.stroke', 'checkboxOutline'),
    _s('checkboxFocusedOutline', 'checkbox.focused.stroke', 'checkboxOutline'),
    _s('checkboxErrorOutline', 'checkbox.error.stroke', 'error'),
    _s(
      'checkboxDisabled',
      'checkbox.disabled.fill',
      'surface',
      'onSurface',
      0.38,
    ),
    _s(
      'checkboxDisabledOutline',
      'checkbox.disabled.stroke',
      'surface',
      'onSurface',
      0.38,
    ),
    _s('radioSelected', 'radio.selected.mark', 'primary'),
    _s('radioOutline', 'radio.enabled.stroke', 'onSurfaceVariant'),
    _s('radioHoveredOutline', 'radio.hovered.stroke', 'radioOutline'),
    _s('radioDisabled', 'radio.disabled.stroke', 'surface', 'onSurface', 0.38),
    _s('switchTrackSelected', 'switch.selected.fill', 'primary'),
    _s('switchThumbSelected', 'switch.selected.mark', 'onPrimary'),
    _s('switchTrack', 'switch.enabled.fill', 'surfaceContainerHighest'),
    _s('switchThumb', 'switch.enabled.mark', 'outline'),
    _s('switchOutline', 'switch.enabled.stroke', 'outline'),
    _s(
      'switchDisabledTrack',
      'switch.disabled.fill',
      'surface',
      'onSurface',
      0.12,
    ),
    _s('tabLabel', 'tab.selected.label', 'primary'),
    _s('tabUnselectedLabel', 'tab.enabled.label', 'onSurfaceVariant'),
    _s('tabIndicator', 'tab.selected.stroke', 'primary'),
    _s('onTextButton', 'textButton.enabled.label', 'primary'),
    _s(
      'textButtonHovered',
      'textButton.hovered.fill',
      'transparent',
      'onTextButton',
      0.08,
    ),
    _s(
      'textButtonPressed',
      'textButton.pressed.fill',
      'transparent',
      'onTextButton',
      0.1,
    ),
    _s(
      'onTextButtonDisabled',
      'textButton.disabled.label',
      'surface',
      'onSurface',
      0.38,
    ),
  ];
}
