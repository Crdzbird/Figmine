import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/inference/color/color_bindings.dart';
import 'package:figmine/src/inference/components/component_sample.dart';
import 'package:figmine/src/inference/stats/text_recorder.dart';
import 'package:figmine/src/inference/stats/text_usage.dart';

/// Counts how the screens use colors, spacing, radii, text and components.
final class UsageStats {
  /// Creates empty statistics.
  factory() = UsageStats._;

  new _();

  /// Area covered by each background color.
  final Map<int, double> backgroundArea = {};

  /// Layers filled with each background color.
  final Map<int, int> backgroundLayers = {};

  /// Characters drawn in each text color.
  final Map<int, int> textCharacters = {};

  /// Layers stroked with each color.
  final Map<int, int> strokes = {};

  /// Auto layout paddings and gaps.
  final Map<int, int> spacing = {};

  /// Corner radii, pills excluded.
  final Map<int, int> radii = {};

  /// Text styles keyed by family, size, weight and line height.
  final Map<String, TextUsage> text = {};

  /// Variables bound to each color, with how often.
  final ColorBindings bindings = ColorBindings();

  /// Measured component instances.
  final List<ComponentSample> samples = [];

  /// Number of fully rounded layers.
  int pills = 0;

  /// Number of analyzed frames, which also numbers the current one.
  int frames = 0;

  /// The frames each fill and text color appears in, by number.
  final Map<int, Set<int>> colorFrames = {};

  /// Total area of every filled layer.
  double totalArea = 0;

  /// The fill of each analyzed frame itself, with how many frames.
  final Map<int, int> frameFills = {};

  /// Layers filled with each color plus one use per 20 characters of text.
  Map<int, int> get colorUses {
    final uses = {...backgroundLayers};
    for (final e in textCharacters.entries) {
      count(uses, e.key, (e.value / 20).ceil());
    }
    return uses;
  }

  /// Adds [n] to [key] of [counts].
  static void count<K>(Map<K, int> counts, K key, [int n = 1]) =>
      counts[key] = (counts[key] ?? 0) + n;

  /// Records a TEXT layer with Figma [style] and [characters].
  void addText(Map<String, Object?> style, int characters) =>
      TextRecorder.add(text, style, characters);

  /// Ranks the keys of [counts] from most to least used.
  static List<int> ranked(Map<int, num> counts) =>
      counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));

  /// Children of a node, for walkers.
  static Iterable<Map<String, Object?>> children(Map<String, Object?> node) =>
      Json.list(node['children']).map(Json.map);
}
