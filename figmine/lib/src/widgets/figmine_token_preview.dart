import 'package:figmine/src/widgets/figmine_curve_painter.dart';
import 'package:flutter/widgets.dart';

/// A small picture of a token value: a swatch, a bar, a shadowed card, a
/// curve, or a text sample in the font or weight.
final class FigmineTokenPreview extends StatelessWidget {
  /// Creates a preview of [value].
  const factory({required Object value, Key? key}) = FigmineTokenPreview._;

  const new _({required this.value, super.key});

  /// The token value.
  final Object value;

  @override
  Widget build(BuildContext context) {
    final ink =
        DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);
    final radius = BorderRadius.circular(6);
    final edge = Border.all(color: ink.withValues(alpha: 0.2));
    Widget bar(double width) => Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: width.clamp(2, 56),
        height: 8,
        child: ColoredBox(color: ink.withValues(alpha: 0.6)),
      ),
    );
    return switch (value) {
      final Color c => DecoratedBox(
        decoration: BoxDecoration(color: c, borderRadius: radius, border: edge),
      ),
      final double d => bar(d),
      final Duration d => bar(d.inMilliseconds / 10),
      final Curve c => CustomPaint(painter: FigmineCurvePainter(c, ink)),
      final FontWeight w => Text(
        'Aa',
        style: TextStyle(fontWeight: w, fontSize: 20),
      ),
      final String family => Text(
        'Aa',
        style: TextStyle(fontFamily: family, fontSize: 20),
      ),
      final List<BoxShadow> s => Padding(
        padding: const EdgeInsets.all(6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: radius,
            boxShadow: s,
          ),
        ),
      ),
      final Gradient g => DecoratedBox(
        decoration: BoxDecoration(gradient: g, borderRadius: radius),
      ),
      final bool on => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? ink : null,
              border: Border.all(color: ink),
            ),
          ),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
