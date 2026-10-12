import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/lock/lock_symbol.dart';
import 'package:figmine/src/naming/dart_identifier.dart';

/// Writes deprecated constants kept for code that still uses them.
abstract final class DeprecatedMembers {
  /// Groups `Class.member` symbols by class.
  static Map<String, Map<String, LockSymbol>> byClass(
    Map<String, LockSymbol> symbols,
  ) {
    final classes = <String, Map<String, LockSymbol>>{};
    for (final entry in symbols.entries) {
      final dot = entry.key.indexOf('.');
      final name = entry.key.substring(0, dot);
      classes.putIfAbsent(name, () => {})[entry.key.substring(dot + 1)] =
          entry.value;
    }
    return classes;
  }

  /// Source of [members], indented for a class body.
  static String write(Map<String, LockSymbol> members) {
    final buffer = StringBuffer();
    for (final MapEntry(key: name, value: symbol) in members.entries) {
      final reason =
          'Removed from Figma (${symbol.token}). Kept until no code uses it.';
      buffer
        ..write(DocComment.render([DocComment.escape(reason)], indent: 2))
        ..writeln('  @Deprecated(${DartSource.string(reason)})')
        ..writeln('  static const ${symbol.type} $name = ${symbol.value};')
        ..writeln();
    }
    return buffer.toString();
  }

  static const Set<String> _core = {'double', 'String', 'bool', 'Duration'};

  /// A library per class in [kept] that no [live] class carries on, by
  /// path under [folder].
  static Map<String, String> orphans(
    CodegenContext context,
    String folder,
    Map<String, Map<String, LockSymbol>> kept,
    Set<String> live,
  ) => {
    for (final MapEntry(key: name, value: members) in kept.entries)
      if (!live.contains(name))
        '$folder/${DartIdentifier.snake([name])}.g.dart': library(
          context.header(
            imports: [
              if (members.values.any((s) => !_core.contains(s.type)))
                context.materialImport,
            ],
          ),
          name,
          members,
        ),
  };

  /// A library with a whole class [name] that no longer exists.
  static String library(
    String header,
    String name,
    Map<String, LockSymbol> members,
  ) => [
    header,
    '\n/// Constants removed from Figma, kept for existing code.\n',
    'abstract final class $name {\n',
    write(members),
    '}\n',
  ].join();
}
