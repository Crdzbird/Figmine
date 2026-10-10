/// Points at the token another token aliases.
final class TokenRef {
  /// Creates a reference to [path] in [collection], in [mode] when the
  /// target collection has several modes.
  const factory({
    required String collection,
    required List<String> path,
    String? mode,
  }) = TokenRef._;

  const new _({required this.collection, required this.path, this.mode});

  /// Name of the target collection.
  final String collection;

  /// Name segments of the target token.
  final List<String> path;

  /// Mode of the target, or null for single mode collections.
  final String? mode;

  /// Readable form, for example `palette/blue/500 (Primitives)`.
  String get label => '${path.join('/')} ($collection)';
}
