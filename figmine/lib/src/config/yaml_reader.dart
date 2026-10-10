import 'package:figmine/src/config/config_exception.dart';
import 'package:figmine/src/config/config_keys.dart';

/// Typed access to one section of the YAML configuration.
final class YamlReader {
  /// Wraps [map], reporting problems under [section].
  ///
  /// Throws when the section holds a setting figmine does not know.
  factory(Map<Object?, Object?> map, String section) = YamlReader._;

  new _(this.map, this.section) {
    ConfigKeys.check(section, map);
  }

  /// The raw section.
  final Map<Object?, Object?> map;

  /// The section name used in error messages.
  final String section;

  /// Reads a required string.
  String requireString(String key) {
    final value = string(key);
    if (value != null && value.isNotEmpty) return value;
    throw ConfigException('`$section.$key` is required.');
  }

  /// Reads an optional string. Numbers are accepted and converted.
  String? string(String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is String || value is num) return '$value';
    throw ConfigException('`$section.$key` must be a string.');
  }

  /// Reads an optional list of strings. A single string becomes one item.
  List<String> strings(String key) {
    final value = map[key];
    if (value == null) return const [];
    if (value is String) return [value];
    if (value is List) return [for (final item in value) '$item'];
    throw ConfigException('`$section.$key` must be a list.');
  }

  /// Reads an optional string to string map.
  Map<String, String> stringMap(String key) {
    final value = map[key];
    if (value == null) return const {};
    if (value is Map) {
      return {for (final e in value.entries) '${e.key}': '${e.value}'};
    }
    throw ConfigException('`$section.$key` must be a map.');
  }

  /// Reads an optional boolean.
  bool? boolean(String key) {
    final value = map[key];
    if (value == null || value is bool) return value as bool?;
    throw ConfigException('`$section.$key` must be true or false.');
  }

  /// Reads names given as a list, or as a map of name to optional value.
  Map<String, String?> nameMap(String key) {
    final value = map[key];
    if (value is Map) {
      return {
        for (final e in value.entries)
          '${e.key}': e.value == null ? null : '${e.value}',
      };
    }
    return {for (final name in strings(key)) name: null};
  }

  /// Reads an optional nested section.
  YamlReader? optionalChild(String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is Map) return YamlReader(value, '$section.$key');
    throw ConfigException('`$section.$key` must be a map.');
  }

  /// Reads a nested section, using an empty one when absent.
  YamlReader child(String key) =>
      optionalChild(key) ?? YamlReader(const {}, '$section.$key');
}
