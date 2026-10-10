import 'package:figmine_example/app/swatch_tile.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// The color scheme roles, then every color token with its mode.
final class ColorSection extends StatelessWidget {
  /// Creates the section with page [padding].
  const factory({required EdgeInsets padding, Key? key}) = ColorSection._;

  const new _({required this.padding, super.key});

  /// Space around the list, from the spacing modes.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColorScheme;
    return ListView(
      padding: padding,
      children: [
        SwatchTile(label: 'scheme.primary', color: colors.primary),
        SwatchTile(label: 'scheme.onPrimary', color: colors.onPrimary),
        SwatchTile(label: 'scheme.surface', color: colors.surface),
        SwatchTile(label: 'scheme.success', color: colors.success),
        SwatchTile(label: 'scheme.error', color: colors.error),
        const Divider(),
        for (final token in [
          ...appPrimitivesColorTokens,
          ...appSemanticColorTokens,
        ])
          SwatchTile(
            label: [token.collection, token.path, ?token.mode].join(' / '),
            color: token.value,
          ),
      ],
    );
  }
}
