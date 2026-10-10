import 'package:figmine/figmine.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Buttons, inputs, chips and selection controls in their resting and
/// disabled states, all styled by the generated component themes.
final class ComponentSection extends StatelessWidget {
  /// Creates the section with page [padding].
  const factory({required EdgeInsets padding, Key? key}) = ComponentSection._;

  const new _({required this.padding, super.key});

  /// Space around the list, from the spacing modes.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final gap = context.appSpacing.gutter;
    void tap() {}
    void pick(Object? _) {}
    return ListView(
      padding: padding,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            FilledButton(onPressed: tap, child: const Text('Filled')),
            OutlinedButton(onPressed: tap, child: const Text('Outlined')),
            TextButton(onPressed: tap, child: const Text('Text')),
            const FilledButton(onPressed: null, child: Text('Disabled')),
          ],
        ),
        SizedBox(height: context.appSpacing.sectionGap),
        const TextField(decoration: InputDecoration(labelText: 'Email')),
        SizedBox(height: gap),
        Wrap(
          spacing: gap,
          children: [
            FilterChip(
              label: const Text('Selected'),
              selected: true,
              onSelected: pick,
            ),
            FilterChip(label: const Text('Chip'), onSelected: pick),
          ],
        ),
        CheckboxListTile(
          value: true,
          onChanged: pick,
          title: const Text('Checkbox'),
        ),
        RadioGroup<int>(
          groupValue: 1,
          onChanged: pick,
          child: const RadioListTile<int>(value: 1, title: Text('Radio')),
        ),
        SwitchListTile(
          value: true,
          onChanged: pick,
          title: const Text('Switch'),
        ),
        SizedBox(height: context.appSpacing.sectionGap),
        Wrap(
          spacing: gap,
          children: [
            for (final icon in AppIcons.values)
              FigmineIcon(
                icon,
                size: 32,
                color: context.appColorScheme.primary,
              ),
          ],
        ),
      ],
    );
  }
}
