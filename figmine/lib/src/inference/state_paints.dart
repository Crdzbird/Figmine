import 'package:figmine/src/inference/button_variant.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_samples.dart';
import 'package:figmine/src/inference/component_state.dart';

/// A color seen in the screens, with the variable bound to it, if any.
typedef StatePaint = ({int argb, String? variable});

/// Reads the colors of component states from the variants in the screens.
abstract final class StatePaints {
  /// Components whose states figmine reads: their key, kind, and the
  /// style of buttons.
  static const List<(String, ComponentKind, ButtonVariant)> components = [
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

  /// The most common fill, label and stroke of each state of the default
  /// variant of each kind, keyed like `button.hovered.fill`.
  static Map<String, StatePaint> collect(List<ComponentSample> samples) {
    final paints = <String, StatePaint>{};
    for (final (key, kind, variant) in components) {
      List<ComponentSample> pool({required bool parts}) =>
          ComponentSamples.select(
            kind,
            samples,
            states: true,
            parts: parts,
            variant: variant,
          ).samples;
      for (final (part, read, parts)
          in <(String, StatePaint? Function(ComponentSample), bool)>[
            ('fill', (s) => _paint(s.fill, s.fillVariable), false),
            ('label', _label, true),
            ('stroke', (s) => _paint(s.stroke, s.strokeVariable), false),
            ('mark', (s) => _paint(s.mark, s.markVariable), false),
          ]) {
        for (final entry in _byState(pool(parts: parts)).entries) {
          final common = _mostCommon(entry.value.map(read).nonNulls);
          if (common == null) continue;
          paints['$key.${entry.key.name}.$part'] = common;
        }
      }
    }
    return paints;
  }

  static Map<ComponentState, List<ComponentSample>> _byState(
    List<ComponentSample> pool,
  ) {
    final byState = <ComponentState, List<ComponentSample>>{};
    for (final sample in pool) {
      final state = ComponentState.of(sample.name);
      if (state != null) (byState[state] ??= []).add(sample);
    }
    return byState;
  }

  /// The text color, or for icon only components the icon color.
  static StatePaint? _label(ComponentSample s) => s.label == null
      ? _paint(s.mark, s.markVariable)
      : _paint(s.label, s.labelVariable);

  static StatePaint? _paint(int? argb, String? variable) =>
      argb == null ? null : (argb: argb, variable: variable);

  static StatePaint? _mostCommon(Iterable<StatePaint> paints) {
    final counts = <StatePaint, int>{};
    for (final paint in paints) {
      counts[paint] = (counts[paint] ?? 0) + 1;
    }
    final ranked = counts.keys.toList()
      ..sort((a, b) => counts[b]! - counts[a]!);
    return ranked.firstOrNull;
  }
}
