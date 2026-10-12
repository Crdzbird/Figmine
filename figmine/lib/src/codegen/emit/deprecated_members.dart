import 'package:figmine/src/codegen/emit/codegen_context.dart';
import 'package:figmine/src/codegen/emit/dart_source.dart';
import 'package:figmine/src/codegen/emit/doc_comment.dart';
import 'package:figmine/src/lock/lock_symbol.dart';

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

  /// The library of the classes in [kept] that no [live] class carries on,
  /// or null when every class still exists.
  static String? orphans(
    CodegenContext context,
    Map<String, Map<String, LockSymbol>> kept,
    Set<String> live,
  ) {
    final gone = {
      for (final entry in kept.entries)
        if (!live.contains(entry.key)) entry.key: entry.value,
    };
    if (gone.isEmpty) return null;
    final symbols = gone.values.expand((m) => m.values);
    final flutter = symbols.any((s) => !_core.contains(s.type));
    final imports = [if (flutter) context.materialImport];
    return library(context.header(imports: imports), gone);
  }

  /// A library with whole classes that no longer exist.
  static String library(
    String header,
    Map<String, Map<String, LockSymbol>> classes,
  ) {
    final buffer = StringBuffer(header);
    for (final entry in classes.entries) {
      buffer
        ..writeln()
        ..writeln('/// Constants removed from Figma, kept for existing code.')
        ..writeln('abstract final class ${entry.key} {')
        ..write(write(entry.value))
        ..writeln('}');
    }
    return buffer.toString();
  }
}
