import 'package:figmine/src/adopt/literal_usage.dart';

/// Picks the scheme role to suggest for a color used a certain way.
abstract final class RolePreference {
  static const List<String> _text = [
    'onSurface',
    'onSurfaceVariant',
    'onPrimary',
    'onSecondary',
    'onTertiary',
    'onError',
    'onPrimaryContainer',
    'onSecondaryContainer',
    'onTertiaryContainer',
    'onErrorContainer',
    'onInverseSurface',
    'primary',
    'secondary',
    'tertiary',
    'error',
  ];

  static const List<String> _background = [
    'surface',
    'primary',
    'secondary',
    'tertiary',
    'error',
    'surfaceContainerLowest',
    'surfaceContainerLow',
    'surfaceContainer',
    'surfaceContainerHigh',
    'surfaceContainerHighest',
    'primaryContainer',
    'secondaryContainer',
    'tertiaryContainer',
    'errorContainer',
    'inverseSurface',
  ];

  static const List<String> _outline = ['outline', 'outlineVariant'];

  /// The best of [fields], the scheme fields with one color, for [usage]:
  /// core roles in a natural order, then any field meant for the use, then
  /// the first field.
  static String? pick(List<String> fields, LiteralUsage usage) {
    final order = switch (usage) {
      LiteralUsage.text || LiteralUsage.icon => _text,
      LiteralUsage.background => _background,
      LiteralUsage.outline => _outline,
    };
    for (final role in order) {
      if (fields.contains(role)) return role;
    }
    return fields.where(usage.fitsRole).firstOrNull ?? fields.firstOrNull;
  }
}
