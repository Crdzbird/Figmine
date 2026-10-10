import 'package:figmine/src/config/inference_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/screens/screen_set.dart';

/// Loads the designed screens of a file without downloading it whole.
final class ScreenLoader {
  /// Creates a loader that reads with [client].
  const factory({
    required FigmaClient client,
    required InferenceConfig config,
  }) = ScreenLoader._;

  const new _({required this.client, required this.config});

  /// The Figma client.
  final FigmaClient client;

  /// Which pages and frames to load.
  final InferenceConfig config;

  static const Set<String> _screenTypes = {'FRAME', 'SECTION'};
  static const int _batchSize = 50;

  /// Lists pages and their top-level frames, then loads frames in batches.
  Future<ScreenSet> load(String fileKey) async {
    final pages = await _frameIds(fileKey);
    final ids = pages.keys.take(config.maxFrames).toList();
    final frames = <ScreenFrame>[];
    final styles = <String, Map<String, Object?>>{};
    final components = <String, Map<String, Object?>>{};
    final sets = <String, Map<String, Object?>>{};
    for (final batch in Json.batches(ids, _batchSize)) {
      final nodes = await _nodes(fileKey, batch);
      for (final id in batch) {
        final entry = Json.map(nodes[id]);
        final document = Json.map(entry['document']);
        if (document.isEmpty) continue;
        frames.add((page: pages[id]!, node: document));
        _merge(styles, entry['styles']);
        _merge(components, entry['components']);
        _merge(sets, entry['componentSets']);
      }
    }
    return ScreenSet(
      frames: frames,
      styles: styles,
      components: components,
      componentSets: sets,
    );
  }

  /// Reads [ids] in one request, splitting the batch in halves when
  /// Figma fails to render a response that large.
  Future<Map<String, Object?>> _nodes(String fileKey, List<String> ids) async {
    try {
      final response = await client.getJson('/v1/files/$fileKey/nodes', {
        'ids': ids.join(','),
      });
      return Json.map(response['nodes']);
    } on FigmaException catch (error) {
      if (ids.length < 2 || !_tooLarge.contains(error.statusCode)) rethrow;
      final half = ids.length ~/ 2;
      return {
        ...await _nodes(fileKey, ids.sublist(0, half)),
        ...await _nodes(fileKey, ids.sublist(half)),
      };
    }
  }

  static const Set<int> _tooLarge = {400, 413, 500, 502, 503, 504};

  Future<Map<String, String>> _frameIds(String fileKey) async {
    if (config.nodeIds.isNotEmpty) {
      return {for (final id in config.nodeIds) id: ''};
    }
    final file = await client.getJson('/v1/files/$fileKey', {'depth': '2'});
    final pages = Json.list(Json.map(file['document'])['children']);
    return {
      for (final page in pages.map(Json.map))
        if (config.includesPage('${page['name']}'))
          for (final child in Json.list(page['children']).map(Json.map))
            if (_screenTypes.contains(child['type']) &&
                child['visible'] != false)
              '${child['id']}': '${page['name']}',
    };
  }

  static void _merge(Map<String, Map<String, Object?>> into, Object? from) {
    for (final entry in Json.map(from).entries) {
      into[entry.key] = Json.map(entry.value);
    }
  }
}
