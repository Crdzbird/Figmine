import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';

/// Hands out unique class and member names for the token index.
final class IndexNamer {
  /// Creates a namer that never hands out the reserved class names.
  factory({required String prefix, Set<String> reservedClasses}) = IndexNamer._;

  new _({required this.prefix, Set<String> reservedClasses = const {}}) {
    reservedClasses.forEach(_classes.claim);
  }

  /// Prefix of every class.
  final String prefix;

  final UniqueNamer _classes = UniqueNamer();
  final Map<String, String> _classKeys = {};
  final Map<String, UniqueNamer> _members = {};

  /// Class for [words], the same class for the same [key].
  String type(String key, List<String> words) =>
      _classKeys.putIfAbsent(key, () {
        final name = DartIdentifier.typeName(words);
        return _claim(
          _classes,
          '$prefix${name.isEmpty ? 'Tokens' : name}',
          'Tokens',
        );
      });

  /// A member of [className] named after [leaf].
  String member(String className, String leaf) => _members
      .putIfAbsent(className, UniqueNamer.new)
      .claim(DartIdentifier.camel([leaf]));

  static String _claim(UniqueNamer namer, String name, String suffix) =>
      namer.claim(namer.taken(name) ? '$name$suffix' : name);
}
