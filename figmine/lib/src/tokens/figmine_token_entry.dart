/// One design token with the metadata Figma carries for it.
///
/// Generated token files expose values twice: as constants for code, and
/// as catalogue lists of entries for galleries, documentation and checks
/// against Figma.
final class FigmineTokenEntry<T extends Object> {
  /// Creates an entry.
  const factory({
    required String collection,
    required String path,
    required T value,
    String? mode,
    String? description,
    String? aliases,
  }) = FigmineTokenEntry<T>._;

  const new _({
    required this.collection,
    required this.path,
    required this.value,
    this.mode,
    this.description,
    this.aliases,
  });

  /// Figma collection, for example `Primitives`.
  final String collection;

  /// Figma variable path, for example `palette/blue/500`.
  final String path;

  /// Resolved value: a `Color`, a `double` or a `String`.
  final T value;

  /// Mode of the value, or null for single mode collections.
  final String? mode;

  /// Description written in Figma.
  final String? description;

  /// The token this one aliases, for example `blue/500 (Primitives)`.
  final String? aliases;

  /// The last path segment.
  String get name => path.split('/').last;

  /// Everything above [name], for example `palette/blue`.
  String get group {
    final index = path.lastIndexOf('/');
    return index < 0 ? '' : path.substring(0, index);
  }

  @override
  String toString() =>
      'FigmineTokenEntry($collection/$path${mode == null ? '' : ' [$mode]'})';
}
