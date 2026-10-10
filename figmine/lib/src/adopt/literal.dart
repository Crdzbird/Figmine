import 'package:figmine/src/adopt/literal_kind.dart';

/// A hard coded design value found in a source file: where it is, its
/// source text, its value, an ARGB color or a number, and the constructor
/// and named argument that receive it, such as `TextStyle` and `color`.
typedef Literal = ({
  String path,
  int offset,
  int length,
  int line,
  int column,
  LiteralKind kind,
  String text,
  num value,
  String? owner,
  String? property,
});
