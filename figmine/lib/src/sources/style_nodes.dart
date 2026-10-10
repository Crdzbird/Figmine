import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/style_ref.dart';

/// A style with its definition node.
typedef StyleNode = ({
  String name,
  String type,
  Map<String, Object?> node,
  String description,
});

/// Loads the nodes that hold style values.
abstract final class StyleNodes {
  static const int _batchSize = 50;

  /// Fetches the nodes of [refs], grouped by file and batched.
  static Future<List<StyleNode>> load(
    FigmaClient client,
    List<StyleRef> refs,
  ) async {
    final byFile = <String, List<StyleRef>>{};
    for (final ref in refs) {
      byFile.putIfAbsent(ref.fileKey, () => []).add(ref);
    }
    final result = <StyleNode>[];
    for (final entry in byFile.entries) {
      for (final batch in Json.batches(entry.value, _batchSize)) {
        final response = await client.getJson('/v1/files/${entry.key}/nodes', {
          'ids': batch.map((r) => r.nodeId).join(','),
        });
        final nodes = Json.map(response['nodes']);
        for (final ref in batch) {
          final node = Json.map(Json.map(nodes[ref.nodeId])['document']);
          if (node.isEmpty) continue;
          result.add((
            name: ref.name,
            type: ref.type,
            node: node,
            description: ref.description,
          ));
        }
      }
    }
    return result;
  }
}
