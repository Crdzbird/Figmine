/// Source of the role and text style tables and the text fields the
/// gallery shows.
abstract final class GalleryDataTemplate {
  /// Functions `_roles(ColorScheme)`, `_styles(TextTheme)`, `_controls()`
  /// with unselected and selected toggles and tabs, and `_fields()`, the
  /// text field in its resting, focused, error and disabled states.
  static const String source = '''
Map<String, (Color, Color)> _roles(ColorScheme s) => {
    'primary': (s.primary, s.onPrimary),
    'primaryContainer': (s.primaryContainer, s.onPrimaryContainer),
    'secondary': (s.secondary, s.onSecondary),
    'secondaryContainer': (s.secondaryContainer, s.onSecondaryContainer),
    'tertiary': (s.tertiary, s.onTertiary),
    'tertiaryContainer': (s.tertiaryContainer, s.onTertiaryContainer),
    'error': (s.error, s.onError),
    'errorContainer': (s.errorContainer, s.onErrorContainer),
    'surface': (s.surface, s.onSurface),
    'surfaceContainer': (s.surfaceContainer, s.onSurface),
    'surfaceContainerHighest': (s.surfaceContainerHighest, s.onSurfaceVariant),
    'inverseSurface': (s.inverseSurface, s.onInverseSurface),
};

Map<String, TextStyle?> _styles(TextTheme t) => {
    'displaySmall': t.displaySmall,
    'headlineSmall': t.headlineSmall,
    'titleMedium': t.titleMedium,
    'bodyLarge': t.bodyLarge,
    'bodyMedium': t.bodyMedium,
    'labelLarge': t.labelLarge,
};

Widget _controls() => Wrap(
  spacing: 12,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    Checkbox(value: false, onChanged: (_) {}),
    RadioGroup<int>(
      groupValue: 1,
      onChanged: (_) {},
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [Radio<int>(value: 1), Radio<int>(value: 2)],
      ),
    ),
    Switch(value: false, onChanged: (_) {}),
    const SizedBox(
      width: 260,
      child: DefaultTabController(
        length: 2,
        child: TabBar(tabs: [Tab(text: 'Selected'), Tab(text: 'Tab')]),
      ),
    ),
  ],
);

Widget _fields() => Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    for (final (label, error, enabled, focus) in const [
      ('Text field', null, true, false),
      ('Focused', null, true, true),
      ('Error', 'Check this value', true, false),
      ('Disabled', null, false, false),
    ])
      SizedBox(
        width: 200,
        child: TextField(
          autofocus: focus,
          enabled: enabled,
          decoration: InputDecoration(labelText: label, errorText: error),
        ),
      ),
  ],
);
''';
}
