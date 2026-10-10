import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';
import 'package:figmine/src/tokens/icon_token.dart';

/// An icon token with its generated field name and SVG file name.
typedef NamedIcon = ({IconToken token, String field, String file});

/// Assigns stable, unique Dart names to icons.
abstract final class TokenNaming {
  /// Names every icon token and its SVG file.
  static List<NamedIcon> icons(List<IconToken> tokens) {
    final names = UniqueNamer()..claim('values');
    final files = UniqueNamer();
    return [
      for (final token in tokens)
        (
          token: token,
          field: names.claim(DartIdentifier.camel(token.path)),
          file: '${files.claim(DartIdentifier.snake(token.path))}.svg',
        ),
    ];
  }
}
