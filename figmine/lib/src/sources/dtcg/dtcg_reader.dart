import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/dtcg/dtcg_entry.dart';
import 'package:figmine/src/sources/dtcg/dtcg_files.dart';

/// Flattens design token files into entries.
///
/// A figmine export holds every collection with its modes. Any other file
/// is one collection named after the file, with the mode from a name such
/// as `Semantic.Dark.tokens.json`.
abstract final class DtcgReader {
  /// Collections in order, with their modes in order.
  static Map<String, List<String>> modes(List<DtcgFile> files) {
    final modes = <String, List<String>>{};
    for (final entry in files.expand(entries)) {
      final list = modes.putIfAbsent(entry.collection, () => []);
      if (!list.contains(entry.mode)) list.add(entry.mode);
    }
    return modes;
  }

  /// Every token of [file] in every mode.
  static List<DtcgEntry> entries(DtcgFile file) {
    final figmine = Json.map(Json.map(file.json[r'$extensions'])['figmine']);
    if (figmine['format'] == 'collections') {
      return [
        for (final collection in _groups(file.json))
          ..._walk(
            collection.value,
            collection.key,
            null,
            [],
            _modesOf(collection.value),
          ),
      ];
    }
    final parts = file.name
        .replaceAll(RegExp(r'(\.tokens)?\.json$'), '')
        .split('.');
    final mode = parts.length > 1 ? parts[1] : 'Value';
    return _walk(file.json, parts.first, null, [], [mode]);
  }

  static List<String> _modesOf(Map<String, Object?> group) {
    final ext = Json.map(Json.map(group[r'$extensions'])['figmine']);
    final modes = [for (final m in Json.list(ext['modes'])) '$m'];
    return modes.isEmpty ? const ['Value'] : modes;
  }

  static Iterable<MapEntry<String, Map<String, Object?>>> _groups(
    Map<String, Object?> json,
  ) => json.entries
      .where((e) => !e.key.startsWith(r'$') && e.value is Map)
      .map((e) => MapEntry(e.key, Json.map(e.value)));

  static List<DtcgEntry> _walk(
    Map<String, Object?> node,
    String collection,
    String? inheritedType,
    List<String> path,
    List<String> modes,
  ) {
    final type = node[r'$type'] is String
        ? node[r'$type']! as String
        : inheritedType;
    if (!node.containsKey(r'$value')) {
      return [
        for (final child in _groups(node))
          ..._walk(child.value, collection, type, [...path, child.key], modes),
      ];
    }
    final ext = Json.map(Json.map(node[r'$extensions'])['figmine']);
    final values = Json.map(ext['values']);
    final aliases = Json.map(ext['aliases']);
    final resolved = Json.map(ext['resolved']);
    return [
      for (final mode in modes)
        (
          collection: collection,
          mode: mode,
          path: path,
          type: type ?? '',
          value: values.containsKey(mode) ? values[mode] : node[r'$value'],
          description: '${node[r'$description'] ?? ''}',
          aliasCollection: Json.map(aliases[mode])['collection'] as String?,
          fallback: resolved[mode],
          variableId: ext['variableId'] as String?,
        ),
    ];
  }
}
