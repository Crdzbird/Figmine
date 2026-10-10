import 'package:figmine/src/sources/dtcg/dtcg_entry.dart';

/// Where an alias points: a collection, a mode and a token path.
typedef DtcgTarget = ({String collection, String mode, List<String> path});

/// Resolves `{group.token}` aliases across collections and modes.
final class DtcgResolver {
  /// Indexes [entries], whose collections have the given [modes].
  factory(List<DtcgEntry> entries, Map<String, List<String>> modes) =
      DtcgResolver._;

  new _(List<DtcgEntry> entries, this.modes) {
    for (final entry in entries) {
      _index[_key(entry.collection, entry.mode, entry.path)] = entry;
    }
  }

  /// Modes of each collection, default first.
  final Map<String, List<String>> modes;

  final Map<String, DtcgEntry> _index = {};

  static final RegExp _alias = RegExp(r'^\{(.+)\}$');
  static const int _maxDepth = 16;

  static String _key(String collection, String mode, List<String> path) =>
      '$collection|$mode|${path.join('.')}';

  /// The token [entry] aliases, or null for raw values and broken aliases.
  ///
  /// Looks in the collection named by the export, then in the entry's own
  /// collection, then in a collection named by the first alias segment,
  /// then anywhere. The target uses the same mode name when it has one.
  DtcgTarget? target(DtcgEntry entry) {
    final raw = entry.value;
    final match = raw is String ? _alias.firstMatch(raw.trim()) : null;
    if (match == null) return null;
    final segments = match.group(1)!.split('.');
    final candidates = [
      if (entry.aliasCollection case final c?) (c, segments),
      (entry.collection, segments),
      if (segments.length > 1) (segments.first, segments.sublist(1)),
      for (final c in modes.keys) (c, segments),
    ];
    for (final (collection, path) in candidates) {
      final known = modes[collection];
      if (known == null) continue;
      final mode = known.contains(entry.mode) ? entry.mode : known.first;
      if (_index.containsKey(_key(collection, mode, path))) {
        return (collection: collection, mode: mode, path: path);
      }
    }
    return null;
  }

  static bool _isAlias(Object? value) =>
      value is String && _alias.hasMatch(value.trim());

  /// The entry at [target].
  DtcgEntry? at(DtcgTarget target) =>
      _index[_key(target.collection, target.mode, target.path)];

  /// The final entry after following every alias from [entry].
  DtcgEntry? resolve(DtcgEntry entry, [int depth = 0]) {
    if (depth > _maxDepth) return null;
    final next = target(entry);
    if (next == null) return _isAlias(entry.value) ? null : entry;
    final found = at(next);
    return found == null ? null : resolve(found, depth + 1);
  }
}
