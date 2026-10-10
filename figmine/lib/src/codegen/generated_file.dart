/// A file produced by figmine.
final class GeneratedFile {
  /// Creates a file at [path], relative to the project root.
  const factory({required String path, required String contents}) =
      GeneratedFile._;

  const new _({required this.path, required this.contents});

  /// Path relative to the project root.
  final String path;

  /// File contents.
  final String contents;
}
