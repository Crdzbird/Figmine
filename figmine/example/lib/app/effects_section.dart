import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// The gradient and shadow tokens, and the type scale.
final class EffectsSection extends StatelessWidget {
  /// Creates the section with page [padding].
  const factory({required EdgeInsets padding, Key? key}) = EffectsSection._;

  const new _({required this.padding, super.key});

  /// Space around the list, from the spacing modes.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColorScheme;
    final text = Theme.of(context).textTheme;
    final gap = context.appSpacing.sectionGap;
    final radius = BorderRadius.circular(AppComponents.cardRadius);
    return ListView(
      padding: padding,
      children: [
        DecoratedBox(
          key: const ValueKey('gradient'),
          decoration: BoxDecoration(
            gradient: AppEffectsGradient.brand,
            borderRadius: radius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppComponents.cardPadding),
            child: Text(
              'gradient/brand',
              style: text.headlineSmall?.copyWith(
                color: AppPrimitivesPalette.white,
              ),
            ),
          ),
        ),
        SizedBox(height: gap),
        DecoratedBox(
          key: const ValueKey('shadow'),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: radius,
            boxShadow: AppEffectsElevation.v1,
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppComponents.cardPadding),
            child: Text('elevation/1'),
          ),
        ),
        SizedBox(height: gap),
        Text('Display large', style: text.displayLarge),
        Text('Headline small', style: text.headlineSmall),
        Text('Title medium', style: text.titleMedium),
        Text('Body large', style: text.bodyLarge),
        Text('Body medium', style: text.bodyMedium),
        Text('Label large', style: text.labelLarge),
      ],
    );
  }
}
