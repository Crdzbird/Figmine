import 'package:figmine/src/inference/components/button_variant.dart';
import 'package:figmine/src/inference/components/component_kind.dart';

/// The components whose state colors figmine reads.
abstract final class StateComponents {
  /// Components whose states figmine reads: their key, kind, and the
  /// style of buttons.
  static const List<(String, ComponentKind, ButtonVariant)> all = [
    ('button', ComponentKind.button, ButtonVariant.filled),
    ('outlinedButton', ComponentKind.button, ButtonVariant.outlined),
    ('textButton', ComponentKind.button, ButtonVariant.text),
    ('input', ComponentKind.input, ButtonVariant.filled),
    ('chip', ComponentKind.chip, ButtonVariant.filled),
    ('checkbox', ComponentKind.checkbox, ButtonVariant.filled),
    ('radio', ComponentKind.radio, ButtonVariant.filled),
    ('switch', ComponentKind.toggle, ButtonVariant.filled),
    ('tab', ComponentKind.tab, ButtonVariant.filled),
    ('fab', ComponentKind.fab, ButtonVariant.filled),
    ('navigationBar', ComponentKind.navigationBar, ButtonVariant.filled),
    ('sheet', ComponentKind.bottomSheet, ButtonVariant.filled),
    ('dialog', ComponentKind.dialog, ButtonVariant.filled),
    ('snackbar', ComponentKind.snackbar, ButtonVariant.filled),
    ('tooltip', ComponentKind.tooltip, ButtonVariant.filled),
  ];
}
