/// Builds doc comments that stay within the line limit and lint clean.
abstract final class DocComment {
  static const int _width = 76;

  /// Renders [paragraphs] as `///` lines indented by [indent] spaces.
  ///
  /// Empty paragraphs are skipped, and paragraphs are separated by an empty
  /// doc line. Brackets and angle brackets are escaped so free text from
  /// Figma is not read as references or HTML.
  static String render(List<String> paragraphs, {int indent = 0}) {
    final pad = ' ' * indent;
    final blocks = [
      for (final paragraph in paragraphs)
        if (paragraph.trim().isNotEmpty) _wrap(paragraph, _width - indent),
    ];
    return blocks
        .map((lines) => lines.map((line) => '$pad/// $line\n').join())
        .join('$pad///\n');
  }

  /// Escapes characters dartdoc would interpret in free text.
  static String escape(String text) => text
      .replaceAll('[', r'\[')
      .replaceAll(']', r'\]')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  static List<String> _wrap(String paragraph, int width) {
    final lines = <String>[];
    var line = '';
    for (final word in paragraph.trim().split(RegExp(r'\s+'))) {
      if (line.isNotEmpty && line.length + word.length + 1 > width) {
        lines.add(line);
        line = word;
        continue;
      }
      line = line.isEmpty ? word : '$line $word';
    }
    return [...lines, line];
  }
}
