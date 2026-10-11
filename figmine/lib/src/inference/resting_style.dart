import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/component_state.dart';

/// Judges a component's style on its resting variant.
abstract final class RestingStyle {
  static final RegExp _state = RegExp(
    r'\b(state|status|interaction)s?\s*=\s*[a-z0-9-]+,?\s*',
  );

  /// The samples whose resting variant [matches], so a hovered text button
  /// that shows a border still counts as a text button. A sample without
  /// a resting variant is judged on itself.
  static List<ComponentSample> filter(
    List<ComponentSample> samples,
    bool Function(ComponentSample sample) matches,
  ) {
    String key(ComponentSample s) =>
        '${s.family}|${s.name.replaceAll(_state, '').trim()}';
    final resting = {
      for (final s in samples)
        if (ComponentState.of(s.name) == ComponentState.enabled) key(s): s,
    };
    return [
      for (final s in samples)
        if (matches(resting[key(s)] ?? s)) s,
    ];
  }
}
