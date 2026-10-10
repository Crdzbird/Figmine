import 'package:figmine/src/figma/figma_client.dart';
import 'package:figmine/src/figma/figma_exception.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/sources/style_nodes.dart';
import 'package:figmine/src/sources/style_ref.dart';
import 'package:figmine/src/sources/style_refs.dart';

export 'package:figmine/src/sources/style_nodes.dart' show StyleNode;

/// Loads fill, text and effect styles with the nodes that hold their
/// values.
final class StyleCatalog {
  /// Creates a catalog over [refs].
  const factory({required FigmaClient client, required StyleRefs refs}) =
      StyleCatalog._;

  const new _({required this.client, required this.refs});

  /// The Figma client.
  final FigmaClient client;

  /// Lists styles from every source.
  final StyleRefs refs;

  /// Styles of [fileKey]: published ones, the ones used by [screens], and
  /// the configured libraries. The first source of a name wins.
  Future<List<StyleNode>> fetch(String fileKey, {ScreenSet? screens}) async {
    final found = <String, StyleRef>{};
    void add(Iterable<StyleRef> list) {
      for (final ref in list) {
        found.putIfAbsent('${ref.type}|${ref.name}', () => ref);
      }
    }

    final published = await refs.published(fileKey);
    add(published ?? const []);
    final used = screens?.styles ?? await _fileStyles(fileKey, published);
    for (final entry in used.entries) {
      final style = entry.value;
      if (!StyleRefs.types.contains(style['styleType'])) continue;
      if (style['remote'] == true) {
        final ref = await refs.remote('${style['key']}');
        if (ref != null) add([ref]);
        continue;
      }
      add([
        (
          name: '${style['name']}',
          type: '${style['styleType']}',
          fileKey: fileKey,
          nodeId: entry.key,
          description: '${style['description'] ?? ''}',
        ),
      ]);
    }
    add(await refs.libraries());
    return await StyleNodes.load(client, found.values.toList());
  }

  Future<Map<String, Map<String, Object?>>> _fileStyles(
    String fileKey,
    List<StyleRef>? published,
  ) async {
    if (published != null) return const {};
    final Map<String, Object?> file;
    try {
      file = await client.getJson('/v1/files/$fileKey');
    } on FigmaException catch (error) {
      if (error.statusCode == 404) return const {};
      rethrow;
    }
    return {
      for (final entry in Json.map(file['styles']).entries)
        entry.key: Json.map(entry.value),
    };
  }
}
