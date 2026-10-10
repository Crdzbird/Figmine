import 'package:figmine/src/tokens/token_ref.dart';

/// The resolved value of a token in one mode.
final class TokenValue {
  /// Creates a value that optionally came through an [alias].
  const factory(Object value, {TokenRef? alias}) = TokenValue._;

  const new _(this.value, {this.alias});

  /// A `ColorValue`, a `double` or a `String`.
  final Object value;

  /// The token this value aliases, when it is not a raw value.
  final TokenRef? alias;
}
