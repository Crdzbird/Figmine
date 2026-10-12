import 'package:figmine/src/figma/figma_file_meta.dart';
import 'package:figmine/src/inference/color/screen_evidence.dart';
import 'package:figmine/src/tokens/component_metric.dart';
import 'package:figmine/src/tokens/icon_token.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_collection.dart';

/// Everything figmine extracted from one Figma file.
final class TokenSet {
  /// Creates a token set.
  const factory({
    required FigmaFileMeta meta,
    required List<TokenCollection> collections,
    List<TextStyleToken> textStyles,
    List<IconToken> icons,
    Map<String, ComponentMetric> components,
    ScreenEvidence evidence,
  }) = TokenSet._;

  const new _({
    required this.meta,
    required this.collections,
    this.textStyles = const [],
    this.icons = const [],
    this.components = const {},
    this.evidence = noEvidence,
  });

  /// File name and version information.
  final FigmaFileMeta meta;

  /// Variable collections, or the color styles collection.
  final List<TokenCollection> collections;

  /// Text styles sorted by name.
  final List<TextStyleToken> textStyles;

  /// Icon tokens sorted by name.
  final List<IconToken> icons;

  /// Component dimensions measured in the screens, by name.
  final Map<String, ComponentMetric> components;

  /// What the screens tell about colors: bound variables, color use and
  /// component state colors.
  final ScreenEvidence evidence;
}
