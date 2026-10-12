import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Groups tokens that are linked by aliases, directly or through others.
abstract final class AliasGroups {
  /// The key of the token at [path] in [collection].
  static String key(String collection, List<String> path) =>
      '$collection\u0000${path.join('/')}';

  /// Every token of [collections] by key, and the keys of each group.
  static (Map<String, DesignToken>, List<List<String>>) of(
    List<TokenCollection> collections,
  ) {
    final tokens = {
      for (final c in collections)
        for (final t in c.tokens) key(c.name, t.path): t,
    };
    final parent = {for (final k in tokens.keys) k: k};
    String find(String k) => parent[k] == k ? k : parent[k] = find(parent[k]!);
    for (final c in collections) {
      for (final t in c.tokens) {
        for (final alias in t.values.values.map((v) => v.alias).nonNulls) {
          final target = key(alias.collection, alias.path);
          if (tokens.containsKey(target)) {
            parent[find(key(c.name, t.path))] = find(target);
          }
        }
      }
    }
    final groups = <String, List<String>>{};
    for (final k in tokens.keys) {
      (groups[find(k)] ??= []).add(k);
    }
    return (tokens, groups.values.toList());
  }
}
