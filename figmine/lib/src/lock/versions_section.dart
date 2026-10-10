import 'package:figmine/src/figma/figma_version.dart';

/// Renders the Figma versions saved since the last sync as Markdown.
///
/// Consecutive autosaves by the same person on the same day are grouped.
abstract final class VersionsSection {
  static const int _shown = 15;

  /// Writes the section into [buffer], or nothing without [versions].
  static void write(StringBuffer buffer, List<FigmaVersion> versions) {
    if (versions.isEmpty) return;
    final lines = <({String text, int count})>[];
    for (final v in versions) {
      final date = v.createdAt.length >= 10
          ? v.createdAt.substring(0, 10)
          : v.createdAt;
      final by = v.author.isEmpty ? '' : ' by ${v.author}';
      final title = v.label.isEmpty ? 'Autosave' : '**${v.label}**';
      final note = v.description.isEmpty ? '' : ': ${_line(v.description)}';
      final text = '$date $title$by$note';
      final last = lines.isEmpty ? null : lines.last;
      if (last != null && v.label.isEmpty && last.text == text) {
        lines[lines.length - 1] = (text: text, count: last.count + 1);
        continue;
      }
      lines.add((text: text, count: 1));
    }
    buffer
      ..writeln('### Figma changes (${versions.length} versions)')
      ..writeln();
    for (final line in lines.take(_shown)) {
      final times = line.count > 1 ? ' (${line.count} times)' : '';
      buffer.writeln('- ${line.text}$times');
    }
    final hidden = lines.length - _shown;
    if (hidden > 0) buffer.writeln('- and $hidden older entries');
    buffer.writeln();
  }

  static String _line(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();
}
