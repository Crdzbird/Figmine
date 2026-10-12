import 'package:figmine/src/codegen/states/control_state_specs.dart';
import 'package:figmine/src/codegen/states/outlined_state_specs.dart';
import 'package:figmine/src/codegen/states/surface_state_specs.dart';

/// A component state color of the scheme: its field, the key of the
/// color read from the screens, and the Material default as the `base`
/// field with the `overlay` field on top at `opacity`.
typedef StateSpec = ({
  String name,
  String key,
  String base,
  String? overlay,
  double opacity,
});

/// The component state fields, in resolution order: resting colors come
/// before the states derived from them.
abstract final class StateFieldSpecs {
  /// A spec of [name] for the screen color [key], defaulting to [base],
  /// with [overlay] on top at [opacity] when given.
  static StateSpec spec(
    String name,
    String key,
    String base, [
    String? overlay,
    double opacity = 0,
  ]) => (name: name, key: key, base: base, overlay: overlay, opacity: opacity);

  /// Every field.
  static final List<StateSpec> all = [
    ...OutlinedStateSpecs.all,
    ...ControlStateSpecs.all,
    ...SurfaceStateSpecs.all,
    spec('button', 'button.enabled.fill', 'primary'),
    spec('onButton', 'button.enabled.label', 'onPrimary'),
    spec('buttonHovered', 'button.hovered.fill', 'button', 'onButton', 0.08),
    spec('onButtonHovered', 'button.hovered.label', 'onButton'),
    spec('buttonPressed', 'button.pressed.fill', 'button', 'onButton', 0.1),
    spec('onButtonPressed', 'button.pressed.label', 'onButton'),
    spec('buttonFocused', 'button.focused.fill', 'button', 'onButton', 0.1),
    spec('onButtonFocused', 'button.focused.label', 'onButton'),
    spec(
      'buttonDisabled',
      'button.disabled.fill',
      'surface',
      'onSurface',
      0.12,
    ),
    spec(
      'onButtonDisabled',
      'button.disabled.label',
      'surface',
      'onSurface',
      0.38,
    ),
    spec('input', 'input.enabled.fill', 'surfaceContainerHighest'),
    spec('onInput', 'input.enabled.label', 'onSurface'),
    spec('inputOutline', 'input.enabled.stroke', 'outline'),
    spec('inputHoveredOutline', 'input.hovered.stroke', 'onSurface'),
    spec('inputFocusedOutline', 'input.focused.stroke', 'primary'),
    spec('inputErrorOutline', 'input.error.stroke', 'error'),
    spec('inputDisabled', 'input.disabled.fill', 'surface', 'onSurface', 0.04),
    spec(
      'onInputDisabled',
      'input.disabled.label',
      'surface',
      'onSurface',
      0.38,
    ),
    spec(
      'inputDisabledOutline',
      'input.disabled.stroke',
      'surface',
      'onSurface',
      0.12,
    ),
    spec('chip', 'chip.enabled.fill', 'surface'),
    spec('onChip', 'chip.enabled.label', 'onSurfaceVariant'),
    spec('chipOutline', 'chip.enabled.stroke', 'outlineVariant'),
    spec('chipSelected', 'chip.selected.fill', 'secondaryContainer'),
    spec('onChipSelected', 'chip.selected.label', 'onSecondaryContainer'),
  ];

  /// The resting fill and label fields of the component of [spec], such
  /// as `button` and `onButton`, that its states relate to.
  static (String, String) rest(StateSpec spec) {
    final kind = spec.key.split('.').first;
    return (kind, 'on${kind[0].toUpperCase()}${kind.substring(1)}');
  }
}
