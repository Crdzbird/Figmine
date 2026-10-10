import 'package:figmine/src/inference/backdrop.dart';
import 'package:figmine/src/inference/node_kind.dart';
import 'package:figmine/src/inference/paint_recorder.dart';
import 'package:figmine/src/inference/sample_reader.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:figmine/src/screens/screen_set.dart';

/// Walks the screens and fills statistics for light and dark frames.
///
/// A frame counts as dark mode when its page or name says dark, or when it
/// has a dark background and such frames are at least a quarter of all.
/// A few dark sections, such as footers, stay with the light screens.
final class StatsCollector {
  /// Collects statistics from [screens].
  factory(ScreenSet screens) = StatsCollector._;

  new _(this.screens) {
    final frames = screens.frames;
    final darkShare = frames.isEmpty
        ? 0
        : frames.where((f) => Backdrop.dark(f.node)).length / frames.length;
    for (final frame in frames) {
      final named = '${frame.page} ${frame.node['name']}'.toLowerCase();
      final isDark =
          named.contains('dark') ||
          (darkShare >= 0.25 && Backdrop.dark(frame.node));
      final stats = isDark ? dark : light;
      stats.frames++;
      _walk(frame.node, stats, inside: false);
    }
  }

  /// The analyzed screens.
  final ScreenSet screens;

  /// Statistics of frames with a light background.
  final UsageStats light = UsageStats();

  /// Statistics of frames with a dark background.
  final UsageStats dark = UsageStats();

  final UsageStats _inverse = UsageStats();

  void _walk(
    Map<String, Object?> node,
    UsageStats stats, {
    required bool inside,
    String? set,
    UsageStats? paints,
  }) {
    if (node['visible'] == false) return;
    if (PaintRecorder.add(paints ?? stats, node)) return;
    final inverse =
        paints ?? (stats == light && Backdrop.inverts(node) ? _inverse : null);
    final found = inside ? null : NodeKind.of(screens, node, set);
    if (found != null) {
      stats.samples.add(
        SampleReader.read(
          node,
          found.$1,
          name: found.$2,
          instance: found.$3 != null,
          family: found.$3 ?? '',
        ),
      );
    }
    final variants = node['type'] == 'COMPONENT_SET' ? '${node['name']}' : null;
    for (final child in UsageStats.children(node)) {
      _walk(
        child,
        stats,
        inside: inside || found != null,
        set: variants,
        paints: inverse,
      );
    }
  }
}
