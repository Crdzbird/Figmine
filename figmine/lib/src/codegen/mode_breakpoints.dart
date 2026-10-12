import 'package:figmine/src/codegen/size_class.dart';

/// Maps the modes of a collection onto window size classes.
abstract final class ModeBreakpoints {
  static final RegExp _app = RegExp(r'\bapps?\b');

  /// The mode for each size class, or null when no mode names a size.
  /// Modes that name an app come first, since Flutter builds apps; a class
  /// without its own mode takes the nearest one.
  static Map<SizeClass, String>? of(List<String> modes) {
    final apps = modes.where((m) => _app.hasMatch(m.toLowerCase())).toList();
    final pool = apps.isEmpty ? modes : apps;
    final named = <SizeClass, String>{
      for (final size in SizeClass.values)
        size: ?pool
            .where(
              (m) => RegExp('\\b(${size.words})\\b').hasMatch(m.toLowerCase()),
            )
            .firstOrNull,
    };
    if (named.isEmpty && apps.length != 1) return null;
    final fallback = named.values.firstOrNull ?? pool.first;
    String pick(List<SizeClass> order) =>
        order.map((s) => named[s]).nonNulls.firstOrNull ?? fallback;
    return {
      SizeClass.compact: pick([
        SizeClass.compact,
        SizeClass.medium,
        SizeClass.expanded,
      ]),
      SizeClass.medium: pick([
        SizeClass.medium,
        SizeClass.compact,
        SizeClass.expanded,
      ]),
      SizeClass.expanded: pick([
        SizeClass.expanded,
        SizeClass.medium,
        SizeClass.compact,
      ]),
    };
  }
}
