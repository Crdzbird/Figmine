import 'package:figmine/src/codegen/derive/feedback_lookup.dart';
import 'package:figmine/src/codegen/scheme/scheme_matcher.dart';
import 'package:figmine/src/inference/color/feedback_roles.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Finds the extra fields of the generated color scheme.
abstract final class SchemeExtras {
  /// Returns extra fields: the configured ones, then every token of
  /// `color_scheme.collection` not among the [roles], otherwise the
  /// success, warning and info colors found in Figma.
  static Map<String, ColorCandidate> of(
    SchemeMatcher matcher,
    Map<String, ColorCandidate> roles,
  ) {
    final config = matcher.config;
    final taken = roles.values.map((c) => c.token).toSet();
    return {
      for (final entry in config.extra.entries)
        entry.key: matcher.lookup(entry.value),
      if (config.collection != null)
        for (final candidate in matcher.scoped)
          if (!taken.contains(candidate.token))
            DartIdentifier.camel(candidate.token.path): candidate,
      if (config.collection == null)
        for (final name in FeedbackRoles.names)
          if (!config.extra.containsKey(name))
            name: ?FeedbackLookup.forScheme(name, matcher, roles),
    };
  }
}
