import 'package:figmine/src/codegen/emit/dart_source.dart';

/// A field of a generated ThemeExtension.
typedef ExtensionField = ({String name, String type});

/// Writes `copyWith` and `lerp` for a generated ThemeExtension.
abstract final class ExtensionMethodsWriter {
  /// Returns the `copyWith` override of [className].
  static String copyWith(String className, List<ExtensionField> fields) {
    if (fields.isEmpty) {
      return '  @override\n  $className copyWith() => this;\n';
    }
    final params = DartSource.params([
      for (final f in fields) '${f.type}? ${f.name}',
    ]);
    final args = [
      for (final f in fields) '${f.name}: ${f.name} ?? this.${f.name}',
    ];
    return '  @override\n'
        '  $className copyWith$params =>\n'
        '      ${DartSource.call(className, args)};\n';
  }

  /// Returns the `lerp` override of [className].
  ///
  /// Colors interpolate, every other field switches halfway.
  static String lerp(String className, List<ExtensionField> fields) {
    final signature =
        '$className lerp(ThemeExtension<$className>? other, '
        'double t)';
    if (fields.isEmpty) return '  @override\n  $signature => this;\n';
    final args = [for (final f in fields) _lerpArg(f)];
    return '  @override\n'
        '  $signature {\n'
        '    if (other is! $className) return this;\n'
        '    return ${DartSource.call(className, args)};\n'
        '  }\n';
  }

  static String _lerpArg(ExtensionField f) {
    if (f.type == 'Color') {
      return '${f.name}: Color.lerp(${f.name}, other.${f.name}, t)!';
    }
    return '${f.name}: t < 0.5 ? ${f.name} : other.${f.name}';
  }
}
