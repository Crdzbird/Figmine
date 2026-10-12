import 'package:figmine/src/codegen/states/state_field_specs.dart';

/// The color fields of floating action buttons, navigation bars, sheets,
/// dialogs, snack bars and tooltips, with the Material defaults of each.
abstract final class SurfaceStateSpecs {
  static StateSpec _s(String name, String key, String base) =>
      StateFieldSpecs.spec(name, key, base);

  /// Every field.
  static final List<StateSpec> all = [
    _s('fab', 'fab.enabled.fill', 'primaryContainer'),
    _s('onFab', 'fab.enabled.label', 'onPrimaryContainer'),
    _s('navigationBar', 'navigationBar.enabled.fill', 'surfaceContainer'),
    _s('onNavigationBar', 'navigationBar.enabled.label', 'onSurfaceVariant'),
    _s('sheet', 'sheet.enabled.fill', 'surfaceContainerLow'),
    _s('dialog', 'dialog.enabled.fill', 'surfaceContainerHigh'),
    _s('onDialog', 'dialog.enabled.label', 'onSurface'),
    _s('snackbar', 'snackbar.enabled.fill', 'inverseSurface'),
    _s('onSnackbar', 'snackbar.enabled.label', 'onInverseSurface'),
    _s('tooltip', 'tooltip.enabled.fill', 'inverseSurface'),
    _s('onTooltip', 'tooltip.enabled.label', 'onInverseSurface'),
  ];
}
