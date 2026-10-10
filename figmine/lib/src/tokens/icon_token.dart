/// An icon component exported from Figma as SVG.
final class IconToken {
  /// Creates an icon token.
  const factory({required List<String> path, required String svg}) =
      IconToken._;

  const new _({required this.path, required this.svg});

  /// Name segments, for example `['arrow', 'left']`.
  final List<String> path;

  /// The SVG markup.
  final String svg;

  /// The icon name joined with `/`.
  String get name => path.join('/');
}
