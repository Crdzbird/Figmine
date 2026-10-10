import 'package:figmine/src/lock/lock_file.dart';

/// Names added, removed and changed between two snapshots of one kind.
typedef NameChanges = ({
  List<String> added,
  List<String> removed,
  List<String> changed,
});

/// The difference between the committed lock and freshly fetched tokens.
final class TokenDiff {
  /// Creates a diff.
  const factory({
    required NameChanges tokens,
    required NameChanges typography,
    required NameChanges components,
    required NameChanges icons,
    NameChanges deprecated,
  }) = TokenDiff._;

  const new _({
    required this.tokens,
    required this.typography,
    required this.components,
    required this.icons,
    this.deprecated = (added: const [], removed: const [], changed: const []),
  });

  /// Compares [next] with [previous], which is null on the first run.
  factory between(LockFile? previous, LockFile next) => TokenDiff(
    tokens: _compare(previous?.tokens ?? const {}, next.tokens),
    typography: _compare(previous?.typography ?? const {}, next.typography),
    components: _compare(previous?.components ?? const {}, next.components),
    icons: _compare(previous?.icons ?? const {}, next.icons),
    deprecated: _compare(
      {for (final k in previous?.deprecated.keys ?? const <String>[]) k: ''},
      {for (final k in next.deprecated.keys) k: ''},
    ),
  );

  /// Token changes.
  final NameChanges tokens;

  /// Text style changes.
  final NameChanges typography;

  /// Component dimension changes.
  final NameChanges components;

  /// Icon changes.
  final NameChanges icons;

  /// Constants that started or stopped being kept as deprecated.
  final NameChanges deprecated;

  /// Whether nothing changed.
  bool get isEmpty => [
    tokens,
    typography,
    components,
    icons,
    deprecated,
  ].every((c) => c.added.isEmpty && c.removed.isEmpty && c.changed.isEmpty);

  static NameChanges _compare(
    Map<String, String> before,
    Map<String, String> after,
  ) {
    List<String> sorted(Iterable<String> names) => names.toList()..sort();
    return (
      added: sorted(after.keys.where((k) => !before.containsKey(k))),
      removed: sorted(before.keys.where((k) => !after.containsKey(k))),
      changed: sorted(
        after.keys.where((k) => before.containsKey(k) && before[k] != after[k]),
      ),
    );
  }
}
