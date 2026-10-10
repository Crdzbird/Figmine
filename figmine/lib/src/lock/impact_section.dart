import 'package:figmine/src/migrate/migrations.dart';

/// Renders what a sync does to the code that uses the tokens.
abstract final class ImpactSection {
  static const int _shown = 50;

  /// Writes the section into [buffer], or nothing when code is untouched.
  static void write(StringBuffer buffer, MigrationPlan plan) {
    final renamed = plan.renamed.entries.toList();
    final deprecated = plan.deprecatedIn.entries.toList();
    if (renamed.isEmpty && deprecated.isEmpty && plan.removedUnused == 0) {
      return;
    }
    buffer
      ..writeln('### Code impact')
      ..writeln();
    if (renamed.isNotEmpty) {
      final files = {for (final f in plan.renamedIn.values) ...f};
      buffer.writeln(
        '${renamed.length} tokens were renamed in Figma; '
        '${files.length} files were updated to the new names:',
      );
      for (final entry in renamed.take(_shown)) {
        final uses = plan.renamedIn[entry.key]?.length ?? 0;
        buffer.writeln('- `${entry.key}` to `${entry.value}` ($uses files)');
      }
      buffer.writeln();
    }
    if (deprecated.isNotEmpty) {
      buffer.writeln(
        '${deprecated.length} removed tokens are still used, so they stay '
        'as deprecated constants until the code moves away:',
      );
      for (final entry in deprecated.take(_shown)) {
        final files = (entry.value.toList()..sort()).map((f) => '`$f`');
        buffer.writeln('- `${entry.key}` in ${files.join(', ')}');
      }
      buffer.writeln();
    }
    if (plan.removedUnused > 0) {
      buffer
        ..writeln(
          '${plan.removedUnused} removed tokens were not used by the '
          'code and are gone.',
        )
        ..writeln();
    }
  }
}
