import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders an SVG icon exported by figmine, styled like [Icon].
///
/// Size and color default to the ambient [IconTheme], so icons follow the
/// generated theme in light and dark mode.
final class FigmineIcon extends StatelessWidget {
  /// Creates an icon for the asset at [asset].
  const factory(
    String asset, {
    Key? key,
    double? size,
    Color? color,
    String? semanticLabel,
    String? package,
  }) = FigmineIcon._;

  const new _(
    this.asset, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.package,
  });

  /// Asset path, usually a constant of the generated icons class.
  final String asset;

  /// Icon size. Defaults to [IconThemeData.size].
  final double? size;

  /// Tint color. Defaults to [IconThemeData.color].
  final Color? color;

  /// Label announced by screen readers.
  final String? semanticLabel;

  /// Package that bundles the asset, when not the app itself.
  final String? package;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final dimension = size ?? theme.size ?? 24;
    final tint = color ?? theme.color;
    return SvgPicture.asset(
      asset,
      package: package,
      width: dimension,
      height: dimension,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      colorFilter: tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}
