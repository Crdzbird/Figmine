import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/inference/color_bindings.dart';
import 'package:figmine/src/inference/component_sample.dart';
import 'package:figmine/src/inference/text_usage.dart';

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
  void addText(Map<String, Object?> style, int characters) {
    final family = style['fontFamily'];
    final size = style['fontSize'];
    if (family is! String || size is! num || characters == 0) return;
    final weight = style['fontWeight'];
    final lineHeight = style['lineHeightPx'];
    final spacing = style['letterSpacing'];
    final intrinsic = style['lineHeightUnit'] == 'INTRINSIC_%';
    final height = lineHeight is num && !intrinsic && size > 0
        ? double.parse((lineHeight / size).toStringAsFixed(3))
        : null;
    final w = weight is num ? (weight / 100).round().clamp(1, 9) * 100 : 400;
    final key = '$family|$size|$w|$height';
    final previous = text[key];
    text[key] = (
      family: family,
      size: size.toDouble(),
      weight: w,
      height: height,
      letterSpacing: spacing is num && spacing != 0 ? spacing.toDouble() : null,
      characters: (previous?.characters ?? 0) + characters,
      layers: (previous?.layers ?? 0) + 1,
    );
  }

  /// Ranks the keys of [counts] from most to least used.
  static List<int> ranked(Map<int, num> counts) =>
      counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));

  /// Children of a node, for walkers.
  static Iterable<Map<String, Object?>> children(Map<String, Object?> node) =>
      Json.list(node['children']).map(Json.map);
}
