import 'package:figmine/src/inference/components/button_variant.dart';
import 'package:figmine/src/inference/components/component_kind.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/components/component_state.dart';
import 'package:figmine/src/inference/components/resting_style.dart';
import 'package:figmine/src/inference/components/sample_usage.dart';

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
  static final RegExp _part = RegExp(
    '^[._]|item|label|content|primitive|slot|group',
  );

  static final RegExp _busy = RegExp(
    r'(state|status)\s*=\s*(?!idle|default|enabled|rest|normal)\w|'
    r'disabled\s*=\s*(true|yes)',
  );

  static final RegExp _mobile = RegExp(r'\b(mobile|phone)\b');

  /// Samples of [kind], without parts such as list items, labels and
  /// private building blocks; buttons also need a label and a fill.
  /// Narrower groups are preferred in turn while three samples stay
  /// [measured]: components named for the kind; with [states], variants
  /// that name their state; `Button` over `Split button`; instances over
  /// lookalikes; the most used component; the resting state; mobile
  /// variants; the primary hierarchy of buttons; the most used size; and
  /// the variants the set defines, as instances are often resized. With
  /// [parts], stated items such as navigation items stay. Buttons are of
  /// the [variant] style, and [fixedSize] replaces the most used size.
  static ({List<ComponentSample> samples, String label}) select(
    ComponentKind kind,
    List<ComponentSample> samples, {
    bool Function(ComponentSample sample)? measured,
    bool states = false,
    bool parts = false,
    ButtonVariant variant = ButtonVariant.filled,
    String? fixedSize,
  }) {
    final button = kind == ComponentKind.button;
    final style = variant.matches;
    final hint = RegExp(variant.hint);
    final ofKind = samples.where((s) => s.kind == kind).toList();
    var pool = (button ? RestingStyle.filter(ofKind, style) : ofKind)
        .where(
          (s) =>
              !_part.hasMatch(s.instance ? s.family : s.name) ||
              (parts &&
                  ComponentState.stated(s.name) &&
                  s.family.contains('item')),
        )
        .toList();
    String? main;
    String? size;
    final strong = RegExp(kind.strong);
    final exact = RegExp('^(?:${kind.strong})\$');
    var noun = button ? 'labelled, filled buttons' : '${kind.name} samples';
    final words = <String>[];
    for (final (word, name, keep, least) in <Narrowing>[
      (null, null, (s) => strong.hasMatch(s.family), 3),
      if (states) (null, null, (s) => ComponentState.stated(s.name), 3),
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
      size = fixedSize ?? SampleUsage.size(pool);
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
