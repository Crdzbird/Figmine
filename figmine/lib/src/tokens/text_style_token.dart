/// A Figma text style.
final class TextStyleToken {
  /// Creates a text style token.
  const factory({
    required List<String> path,
    required String fontFamily,
    required double fontSize,
    required int fontWeight,
    double? height,
    double? letterSpacing,
    bool italic,
    String? decoration,
    String description,
  }) = TextStyleToken._;

  const new _({
    required this.path,
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    this.height,
    this.letterSpacing,
    this.italic = false,
    this.decoration,
    this.description = '',
  });

  /// Name segments, for example `['heading', 'large']`.
  final List<String> path;

  /// Font family.
  final String fontFamily;

  /// Font size in logical pixels.
  final double fontSize;

  /// Font weight from 100 to 900.
  final int fontWeight;

  /// Line height as a multiple of [fontSize].
  final double? height;

  /// Letter spacing in logical pixels.
  final double? letterSpacing;

  /// Whether the style is italic.
  final bool italic;

  /// `underline` or `lineThrough`, when decorated.
  final String? decoration;

  /// Description written in Figma.
  final String description;

  /// The style name joined with `/`.
  String get name => path.join('/');
}
