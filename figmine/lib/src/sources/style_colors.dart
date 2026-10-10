import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/figma/json.dart';
import 'package:figmine/src/sources/style_catalog.dart';
import 'package:figmine/src/sources/style_mode_grouper.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Builds a color collection from solid fill styles.
abstract final class StyleColors {
  /// Name of the collection built from styles.
  static const String collectionName = 'Styles';

  /// Returns the fill styles in [styles] as a collection, or null.
  static TokenCollection? collect(List<StyleNode> styles, TokensConfig config) {
    final grouper = StyleModeGrouper(config);
    for (final style in styles) {
      if (style.type != 'FILL') continue;
      final color = _solidFill(style.node);
      if (color == null) continue;
      grouper.add(style.name, color, style.description);
    }
    return grouper.collection(collectionName);
  }

  static ColorValue? _solidFill(Map<String, Object?> node) {
    for (final fill in Json.list(node['fills']).map(Json.map)) {
      if (fill['type'] != 'SOLID' || fill['visible'] == false) continue;
      final opacity = fill['opacity'];
      return ColorValue.tryParse(
        fill['color'],
        opacity: opacity is num ? opacity.toDouble() : 1,
      );
    }
    return null;
  }
}
