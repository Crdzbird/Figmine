import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_type.dart';

/// Sorts collections into the color, typography, units and effects
/// domains.
abstract final class CollectionDomain {
  static const Map<String, Set<String>> _words = {
    'color': {'color', 'colors', 'colour', 'colours', 'palette', 'brand'},
    'typography': {'typography', 'typo', 'font', 'fonts', 'text', 'type'},
    'units': {
      'unit',
      'units',
      'size',
      'sizes',
      'spacing',
      'space',
      'radius',
      'radii',
      'layout',
      'dimension',
      'dimensions',
      'grid',
    },
    'effects': {'effect', 'effects', 'shadow', 'shadows', 'elevation'},
    'motion': {'motion', 'animation', 'animations', 'duration', 'easing'},
  };

  static const Map<String, Set<String>> _generic = {
    'color': {'color', 'colors', 'colour', 'colours'},
    'typography': {'typography', 'typo'},
    'units': {'unit', 'units'},
    'effects': {'effect', 'effects'},
    'motion': {'motion'},
  };

  /// The domain named in the collection name, otherwise the domain of most
  /// of its tokens.
  static String of(TokenCollection collection) {
    final words = DartIdentifier.words(collection.name.split('/')).toSet();
    for (final entry in _words.entries) {
      if (entry.value.intersection(words).isNotEmpty) return entry.key;
    }
    final counts = <TokenType, int>{};
    for (final token in collection.tokens) {
      counts[token.type] = (counts[token.type] ?? 0) + 1;
    }
    final top = counts.entries.fold<MapEntry<TokenType, int>?>(
      null,
      (best, e) => best == null || e.value > best.value ? e : best,
    );
    return switch (top?.key) {
      TokenType.number || TokenType.boolean => 'units',
      TokenType.string || TokenType.fontWeight => 'typography',
      TokenType.shadow || TokenType.gradient => 'effects',
      TokenType.duration || TokenType.curve => 'motion',
      _ => 'color',
    };
  }

  /// File stem inside the domain folder: the collection name without the
  /// generic domain words, such as `core` for `_core/colors`.
  static String stem(TokenCollection collection, String domain) {
    final words = DartIdentifier.words(collection.name.split('/'));
    final kept = words.where((w) => !_generic[domain]!.contains(w)).toList();
    return DartIdentifier.snake(kept.isEmpty ? words : kept);
  }
}
