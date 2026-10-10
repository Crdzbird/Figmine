import 'package:figmine/src/figma/json.dart';

/// Finds icon components inside a Figma node tree.
abstract final class ComponentCollector {
  /// Returns component node ids mapped to their names.
  ///
  /// Variants are named after their set, for example
  /// `arrow/Direction=Left`.
  static Map<String, String> collect(Map<String, Object?> node) {
    final found = <String, String>{};
    _walk(node, null, found);
    return found;
  }

  static void _walk(
    Map<String, Object?> node,
    String? setName,
    Map<String, String> found,
  ) {
    final name = '${node['name']}';
    if (node['type'] == 'COMPONENT') {
      found['${node['id']}'] = setName == null ? name : '$setName/$name';
      return;
    }
    final nextSet = node['type'] == 'COMPONENT_SET' ? name : null;
    for (final child in Json.list(node['children'])) {
      _walk(Json.map(child), nextSet, found);
    }
  }
}
