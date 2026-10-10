import 'package:material_ui/material_ui.dart';

/// A labelled color sample.
final class SwatchTile extends StatelessWidget {
  /// Creates a tile showing [color].
  const factory({required String label, required Color color, Key? key}) =
      SwatchTile._;

  const new _({required this.label, required this.color, super.key});

  /// Token or role name.
  final String label;

  /// The sampled color.
  final Color color;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const SizedBox.square(dimension: 40),
    ),
    title: Text(label),
    subtitle: Text('0x${color.toARGB32().toRadixString(16).toUpperCase()}'),
  );
}
