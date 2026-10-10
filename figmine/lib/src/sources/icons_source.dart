import 'package:figmine/src/config/icons_config.dart';
import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/component_collector.dart';
import 'package:figmine/src/tokens/icon_token.dart';

/// Exports icon components as SVG.
final class IconsSource {
  /// Creates a source that reads with [client].
  const factory({required FigmaClient client, required IconsConfig config}) =
      IconsSource._;

  const new _({required this.client, required this.config});

  /// The Figma client.
  final FigmaClient client;

  /// Icon settings.
  final IconsConfig config;

  /// Fetches and renders every icon component of [fileKey].
  Future<List<IconToken>> fetch(String fileKey) async {
    final response = await client.getJson('/v1/files/$fileKey/nodes', {
      'ids': config.nodeIds.join(','),
    });
    final nodes = Json.map(response['nodes']);
    final names = <String, String>{
      for (final id in config.nodeIds)
        ...ComponentCollector.collect(
          Json.map(Json.map(nodes[id])['document']),
        ),
    };
    final prefix = config.namePrefix;
    final selected = <String, String>{
      for (final entry in names.entries)
        if (entry.value.startsWith(prefix))
          entry.key: entry.value.substring(prefix.length),
    };
    final urls = await _renderUrls(fileKey, selected.keys.toList());
    final icons = <IconToken>[];
    for (final batch in Json.batches(urls.keys.toList(), 8)) {
      final svgs = await Future.wait([
        for (final id in batch) client.download(Uri.parse(urls[id]!)),
      ]);
      for (var i = 0; i < batch.length; i++) {
        icons.add(IconToken(path: _path(selected[batch[i]]!), svg: svgs[i]));
      }
    }
    return icons..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Map<String, String>> _renderUrls(String key, List<String> ids) async {
    final urls = <String, String>{};
    for (final batch in Json.batches(ids, 50)) {
      final response = await client.getJson('/v1/images/$key', {
        'ids': batch.join(','),
        'format': 'svg',
        'svg_simplify_stroke': 'true',
      });
      for (final entry in Json.map(response['images']).entries) {
        final url = entry.value;
        if (url is String) urls[entry.key] = url;
      }
    }
    return urls;
  }

  List<String> _path(String name) => [
    for (final segment in name.split('/'))
      if (segment.trim().isNotEmpty) segment.trim(),
  ];
}
