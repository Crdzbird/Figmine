import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_samples.dart';
import 'package:figmine/src/inference/components/component_state.dart';
import 'package:figmine/src/inference/components/sample_usage.dart';
import 'package:figmine/src/inference/components/state_components.dart';

/// A color seen in the screens, with the variable bound to it, if any.
typedef StatePaint = ({int argb, String? variable});

/// Reads the colors of component states from the variants in the screens.
abstract final class StatePaints {
  /// The most common fill, label and stroke of each state of the default
  /// variant of each kind, keyed like `button.hovered.fill`. Every button
  /// style takes the size the filled button uses.
  static Map<String, StatePaint> collect(List<ComponentSample> samples) {
    final paints = <String, StatePaint>{};
    final buttonSize = SampleUsage.size(
      ComponentSamples.select(
        ComponentKind.button,
        samples,
        states: true,
      ).samples,
    );
    for (final (key, kind, variant) in StateComponents.all) {
      List<ComponentSample> pool({required bool parts}) =>
          ComponentSamples.select(
            kind,
            samples,
            states: true,
            parts: parts,
            variant: variant,
            fixedSize: kind == ComponentKind.button ? buttonSize : null,
          ).samples;
      for (final (part, read, parts)
          in <(String, StatePaint? Function(ComponentSample), bool)>[
            ('fill', (s) => _paint(s.fill, s.fillVariable), false),
            ('label', _label, true),
            ('stroke', (s) => _paint(s.stroke, s.strokeVariable), false),
            ('mark', (s) => _paint(s.mark, s.markVariable), false),
          ]) {
        for (final entry in _byState(pool(parts: parts)).entries) {
          final common = _mostCommon(entry.value, read);
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

  /// The paint most samples show, and on a tie the one the component
  /// set's own variants show, as placed instances may carry overrides.
  static StatePaint? _mostCommon(
    List<ComponentSample> samples,
    StatePaint? Function(ComponentSample) read,
  ) {
    final counts = <StatePaint, int>{};
    final defined = <StatePaint>{};
    for (final sample in samples) {
      final paint = read(sample);
      if (paint == null) continue;
      counts[paint] = (counts[paint] ?? 0) + 1;
      if (sample.definition) defined.add(paint);
    }
    int rank(StatePaint p) => counts[p]! * 2 + (defined.contains(p) ? 1 : 0);
    final ranked = counts.keys.toList()..sort((a, b) => rank(b) - rank(a));
    return ranked.firstOrNull;
  }
}
