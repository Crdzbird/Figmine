/// Source of the gallery widget the preview renders.
abstract final class GalleryTemplate {
  /// A function `_gallery(ThemeData)` showing roles, type and components.
  static const String source = r'''
Widget _gallery(ThemeData theme) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: theme,
  home: Builder(
    builder: (context) {
      final s = Theme.of(context).colorScheme;
      final t = Theme.of(context).textTheme;
      final roles = _roles(s);
      final styles = _styles(t);
      return Scaffold(
        appBar: AppBar(title: const Text('figmine preview')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final role in roles.entries)
                    Container(
                      width: 205,
                      height: 52,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: role.value.$1,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: s.outlineVariant),
                      ),
                      child: Text(
                        role.key,
                        style: t.labelMedium?.copyWith(color: role.value.$2),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              for (final style in styles.entries)
                Text(
                  '${style.key} ${style.value?.fontFamily ?? ''} '
                  '${style.value?.fontSize?.round() ?? ''}',
                  style: style.value,
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton(onPressed: () {}, child: const Text('Filled')),
                  const FilledButton(onPressed: null, child: Text('Disabled')),
                  OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                  TextButton(onPressed: () {}, child: const Text('Text')),
                  const Chip(label: Text('Chip')),
                  FilterChip(
                    label: const Text('Selected'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  Switch(value: true, onChanged: (_) {}),
                  Checkbox(value: true, onChanged: (_) {}),
                ],
              ),
              const SizedBox(height: 16),
              _controls(),
              const SizedBox(height: 16),
              _fields(),
              const SizedBox(height: 16),
              const SizedBox(
                width: 420,
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Card title'),
                    subtitle: Text('Supporting text'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
''';
}
