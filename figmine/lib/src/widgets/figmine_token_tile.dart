import 'package:figmine/src/tokens/figmine_token_entry.dart';
import 'package:figmine/src/widgets/figmine_token_preview.dart';
import 'package:flutter/widgets.dart';

/// One token of a `FigmineGallery`: a preview, its path and its value.
final class FigmineTokenTile extends StatelessWidget {
  /// Creates a tile for [entry].
  const factory({required FigmineTokenEntry<Object> entry, Key? key}) =
      FigmineTokenTile._;

  const new _({required this.entry, super.key});

  /// The token shown.
  final FigmineTokenEntry<Object> entry;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    final muted = style.copyWith(
      color: style.color?.withValues(alpha: 0.6),
      fontSize: (style.fontSize ?? 14) - 2,
    );
    final mode = entry.mode == null ? '' : ' (${entry.mode})';
    final alias = entry.aliases == null ? '' : ', from ${entry.aliases}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 40,
            child: FigmineTokenPreview(value: entry.value),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${entry.path}$mode'),
                Text('${describe(entry.value)}$alias', style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The value as short text, such as `#FF3D5AFE` or `150 ms`.
  static String describe(Object value) => switch (value) {
    final Color c =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
    final double d => _number(d),
    final Duration d => '${_number(d.inMicroseconds / 1000)} ms',
    final Cubic c => 'Cubic(${c.a}, ${c.b}, ${c.c}, ${c.d})',
    final FontWeight w => 'w${w.value}',
    final List<BoxShadow> s => '${s.length} shadow, blur ${s.first.blurRadius}',
    final Gradient g => '${g.runtimeType}, ${g.colors.length} colors',
    _ => '$value',
  };

  static String _number(double d) =>
      d == d.roundToDouble() ? '${d.round()}' : '$d';
}
