import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/json.dart';

/// Reads the modes of a Figma variable collection.
abstract final class CollectionModes {
  /// Mode names with the default mode first.
  static List<String> names(Map<String, Object?> collection) {
    final defaultId = '${collection['defaultModeId']}';
    final modes = Json.list(collection['modes']).map(Json.map).toList();
    return [
      for (final mode in modes)
        if ('${mode['modeId']}' == defaultId) '${mode['name']}',
      for (final mode in modes)
        if ('${mode['modeId']}' != defaultId) '${mode['name']}',
    ];
  }

  /// Picks the light and dark mode out of [modes].
  ///
  /// A mode matches when its name contains the configured mode name, case
  /// insensitive. Light falls back to the first mode, dark to light.
  static ({String light, String dark}) pick(
    List<String> modes,
    TokensConfig config,
  ) {
    final light = _containing(modes, config.lightMode) ?? modes.first;
    final dark = _containing(modes, config.darkMode) ?? light;
    return (light: light, dark: dark);
  }

  /// Returns the mode of [collection] called [name], or its default mode.
  static ({String id, String name})? resolve(
    Map<String, Object?> collection,
    String name,
  ) {
    final modes = Json.list(collection['modes']).map(Json.map).toList();
    for (final mode in modes) {
      if ('${mode['name']}'.toLowerCase() == name.toLowerCase()) {
        return (id: '${mode['modeId']}', name: '${mode['name']}');
      }
    }
    for (final mode in modes) {
      if (mode['modeId'] == collection['defaultModeId']) {
        return (id: '${mode['modeId']}', name: '${mode['name']}');
      }
    }
    return null;
  }

  static String? _containing(List<String> modes, String needle) {
    for (final mode in modes) {
      if (mode.toLowerCase().contains(needle.toLowerCase())) return mode;
    }
    return null;
  }
}
