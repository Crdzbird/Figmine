import 'package:figmine/src/adopt/literal.dart';

/// What to use instead of a hard coded `literal`: the const token that
/// replaces it when exactly one fits best, other tokens with the same
/// value, and for colors the theme aware scheme role.
typedef Suggestion = ({
  Literal literal,
  String? constant,
  List<String> others,
  String? themed,
});
