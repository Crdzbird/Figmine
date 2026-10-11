import 'package:figmine/src/inference/button_variant.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/sample_usage.dart';

/// A preference among samples: an adjective or a noun for the label, the
/// test a sample must pass, and how many measured samples must pass it.
typedef Narrowing = (
  String? word,
  String? noun,
  bool Function(ComponentSample sample) keep,
  int least,
);

/// Picks the samples that describe the default component of a kind.
abstract final class ComponentSamples {
  static final RegExp _part = RegExp('item|label|content|primitive|slot|group');

  static final RegExp _busy = RegExp(
    r'(state|status)\s*=\s*(?!idle|default|enabled|rest|normal)\w|'
    r'disabled\s*=\s*(true|yes)',
  );

  static final RegExp _mobile = RegExp(r'\b(mobile|phone)\b');

  /// Samples of [kind], without parts of larger components such as list
  /// items and labels; buttons also need a label and a fill. Narrower
  /// groups are preferred in turn while at least three of their samples
  /// are [measured]: components and then names that say the kind
  /// outright, such as a `Tooltip` set over an icon layer called tooltip,
  /// with a component named just for the kind, such as `Button`, before
  /// variations such as `Split button`,
  /// component instances
  /// over lookalike layers, the most used component, the resting state,
  /// mobile variants (even a single one, as the app targets phones), the
  /// primary hierarchy of buttons and the size the screens use most, as
  /// systems disagree on which size is the default, and then the variants
  /// the component set defines, as placed instances are often resized.
  /// With [states], every interaction state stays, for reading state
  /// colors. Buttons are of the [variant] style, filled by default.
  static ({List<ComponentSample> samples, String label}) select(
    ComponentKind kind,
    List<ComponentSample> samples, {
    bool Function(ComponentSample sample)? measured,
    bool states = false,
    ButtonVariant variant = ButtonVariant.filled,
  }) {
    final button = kind == ComponentKind.button;
    final style = variant.matches;
    final hint = RegExp(variant.hint);
    var pool = samples
        .where((s) => s.kind == kind)
        .where((s) => !button || style(s))
        .where((s) => !_part.hasMatch(s.instance ? s.family : s.name))
        .toList();
    String? main;
    String? size;
    final strong = RegExp(kind.strong);
    final exact = RegExp('^(?:${kind.strong})\$');
    var noun = button ? 'labelled, filled buttons' : '${kind.name} samples';
    final words = <String>[];
    for (final (word, name, keep, least) in <Narrowing>[
      (null, null, (s) => strong.hasMatch(s.family), 3),
      (null, null, (s) => exact.hasMatch(s.family.trim()), 3),
      (null, null, (s) => strong.hasMatch(s.name), 3),
      (null, 'component instances', (s) => s.instance, 3),
      (null, '`main` instances', (s) => s.family == main, 3),
      if (!states) ('resting', null, (s) => !_busy.hasMatch(s.name), 3),
      ('mobile', null, (s) => _mobile.hasMatch(s.name), states ? 3 : 1),
      if (button && variant == ButtonVariant.filled)
        ('primary', null, (s) => hint.hasMatch(s.name), 3),
      if (button && variant != ButtonVariant.filled)
        (null, null, (s) => hint.hasMatch(s.name), 3),
      ('`size`', null, (s) => size != null && SampleUsage.sizeOf(s) == size, 3),
      if (!states)
        (null, '`main` component definitions', (s) => s.definition, 3),
    ]) {
      main = SampleUsage.family(pool);
      size = SampleUsage.size(pool);
      final narrowed = pool.where(keep).toList();
      final count = narrowed.where((s) => measured?.call(s) ?? true).length;
      if (count < least) continue;
      pool = narrowed;
      noun = name?.replaceAll('`main`', '`${main ?? ''}`') ?? noun;
      if (word != null) words.add(word.replaceAll('`size`', size ?? ''));
    }
    return (samples: pool, label: [...words, noun].join(' '));
  }
}
