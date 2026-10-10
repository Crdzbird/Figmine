import 'package:figmine/src/inference/button_variant.dart';
import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/usage_stats.dart';

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

  static final RegExp _medium = RegExp(r'size\s*=\s*(m|md|medium)\b');

  /// Samples of [kind], without parts of larger components such as list
  /// items and labels; buttons also need a label and a fill. Narrower
  /// groups are preferred in turn while at least three of their samples
  /// are [measured]: components and then names that say the kind
  /// outright, such as a `Tooltip` set over an icon layer called tooltip,
  /// component instances
  /// over lookalike layers, the most used component, the resting state,
  /// mobile variants (even a single one, as the app targets phones), the
  /// primary hierarchy of buttons and the medium size. With [states], every
  /// interaction state stays, for reading state colors. Buttons are of the
  /// [variant] style, filled by default.
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
    final strong = RegExp(kind.strong);
    var noun = button ? 'labelled, filled buttons' : '${kind.name} samples';
    final words = <String>[];
    for (final (word, name, keep, least) in <Narrowing>[
      (null, null, (s) => strong.hasMatch(s.family), 3),
      (null, null, (s) => strong.hasMatch(s.name), 3),
      (null, 'component instances', (s) => s.instance, 3),
      (null, '`main` instances', (s) => s.family == main, 3),
      if (!states) ('resting', null, (s) => !_busy.hasMatch(s.name), 3),
      ('mobile', null, (s) => _mobile.hasMatch(s.name), states ? 3 : 1),
      if (button && variant == ButtonVariant.filled)
        ('primary', null, (s) => hint.hasMatch(s.name), 3),
      if (button && variant != ButtonVariant.filled)
        (null, null, (s) => hint.hasMatch(s.name), 3),
      ('medium', null, (s) => _medium.hasMatch(s.name), 3),
    ]) {
      main = _mostUsed(pool);
      final narrowed = pool.where(keep).toList();
      final count = narrowed.where((s) => measured?.call(s) ?? true).length;
      if (count < least) continue;
      pool = narrowed;
      noun = name?.replaceAll('`main`', '`${main ?? ''}`') ?? noun;
      if (word != null) words.add(word);
    }
    return (samples: pool, label: [...words, noun].join(' '));
  }

  static String? _mostUsed(List<ComponentSample> pool) {
    final families = <String, int>{};
    for (final s in pool.where((s) => s.instance)) {
      UsageStats.count(families, s.family);
    }
    final ranked = families.keys.toList()
      ..sort((a, b) => families[b]! - families[a]!);
    return ranked.firstOrNull;
  }
}
