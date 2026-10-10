import 'package:figmine/src/inference/text_usage.dart';

/// Records text styles by family, size, weight and line height.
abstract final class TextRecorder {
  /// Adds a TEXT layer with Figma [style] and [characters] to [text].
  static void add(
    Map<String, TextUsage> text,
    Map<String, Object?> style,
    int characters,
  ) {
    final family = style['fontFamily'];
    final size = style['fontSize'];
    if (family is! String || size is! num || characters == 0) return;
    final weight = style['fontWeight'];
    final lineHeight = style['lineHeightPx'];
    final spacing = style['letterSpacing'];
    final intrinsic = style['lineHeightUnit'] == 'INTRINSIC_%';
    final height = lineHeight is num && !intrinsic && size > 0
        ? double.parse((lineHeight / size).toStringAsFixed(3))
        : null;
    final w = weight is num ? (weight / 100).round().clamp(1, 9) * 100 : 400;
    final key = '$family|$size|$w|$height';
    final previous = text[key];
    text[key] = (
      family: family,
      size: size.toDouble(),
      weight: w,
      height: height,
      letterSpacing: spacing is num && spacing != 0 ? spacing.toDouble() : null,
      characters: (previous?.characters ?? 0) + characters,
      layers: (previous?.layers ?? 0) + 1,
    );
  }
}
