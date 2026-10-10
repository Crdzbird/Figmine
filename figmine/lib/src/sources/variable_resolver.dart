import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/collection_modes.dart';

/// Resolves variable values, following aliases across collections.
final class VariableResolver {
  /// Creates a resolver over the `meta` maps of the variables endpoint.
  const factory({
    required Map<String, Object?> variables,
    required Map<String, Object?> collections,
  }) = VariableResolver._;

  const new _({required this.variables, required this.collections});

  /// Variables keyed by id.
  final Map<String, Object?> variables;

  /// Variable collections keyed by id.
  final Map<String, Object?> collections;

  static const int _maxDepth = 16;

  /// Returns the variable with [id].
  Map<String, Object?> variable(String id) => Json.map(variables[id]);

  /// Returns the collection that owns the variable with [id].
  Map<String, Object?> collectionOf(String id) =>
      Json.map(collections[variable(id)['variableCollectionId']]);

  /// Value of [id] in the mode called [modeName], before resolving aliases.
  ///
  /// Variables in collections without that mode use their default mode.
  Object? raw(String id, String modeName) {
    final values = Json.map(variable(id)['valuesByMode']);
    final mode = CollectionModes.resolve(collectionOf(id), modeName);
    return values[mode?.id] ?? (values.isEmpty ? null : values.values.first);
  }

  /// Fully resolved value of [id] in the mode called [modeName].
  Object? resolve(String id, String modeName, [int depth = 0]) {
    if (depth > _maxDepth) return null;
    final value = raw(id, modeName);
    final target = aliasOf(value);
    if (target == null) return value;
    return resolve(target, modeName, depth + 1);
  }

  /// Id of the variable [value] points at, or null for raw values.
  static String? aliasOf(Object? value) {
    final alias = Json.map(value);
    if (alias['type'] != 'VARIABLE_ALIAS') return null;
    return '${alias['id']}';
  }
}
