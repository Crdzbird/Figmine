/// Turns Figma names into Dart identifiers and file names.
abstract final class DartIdentifier {
  static final RegExp _words = RegExp(r'[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\d+');

  static final Set<String> _reserved = [
    'assert await break case catch class const continue covariant default ',
    'do else enum extends factory false final finally for if in is late ',
    'new null required rethrow return super switch this throw true try var ',
    'void while with yield values light dark copyWith lerp toString ',
    'hashCode runtimeType',
  ].join().split(' ').toSet();

  /// Splits [segments] into lowercase words.
  static List<String> words(Iterable<String> segments) => [
    for (final segment in segments)
      for (final match in _words.allMatches(segment))
        match.group(0)!.toLowerCase(),
  ];

  /// Builds a lowerCamelCase identifier, for example `brandPrimary`.
  static String camel(Iterable<String> segments) {
    final parts = words(segments);
    if (parts.isEmpty) return 'unnamed';
    final buffer = StringBuffer(parts.first);
    for (final part in parts.skip(1)) {
      buffer
        ..write(part[0].toUpperCase())
        ..write(part.substring(1));
    }
    final name = buffer.toString();
    if (RegExp(r'^\d').hasMatch(name)) return 'v$name';
    if (_reserved.contains(name)) return '${name}Token';
    return name;
  }

  /// Builds an UpperCamelCase identifier, for example `BrandPrimary`.
  static String pascal(Iterable<String> segments) {
    final name = camel(segments);
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  /// Joins capitalized words, for example `PaletteBlue`, or `''`.
  static String typeName(Iterable<String> segments) => [
    for (final word in words(segments))
      '${word[0].toUpperCase()}${word.substring(1)}',
  ].join();

  /// Builds a snake_case name, for example `brand_primary`.
  static String snake(Iterable<String> segments) {
    final parts = words(segments);
    if (parts.isEmpty) return 'unnamed';
    return parts.join('_');
  }
}
