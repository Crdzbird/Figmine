import 'package:figmine/src/tokens/token_type.dart';

/// The Dart types generated for each token type.
abstract final class TokenDartTypes {
  /// Dart type of each token type.
  static const Map<TokenType, String> of = {
    TokenType.color: 'Color',
    TokenType.number: 'double',
    TokenType.string: 'String',
    TokenType.shadow: 'List<BoxShadow>',
    TokenType.gradient: 'Gradient',
    TokenType.boolean: 'bool',
    TokenType.duration: 'Duration',
    TokenType.curve: 'Curve',
    TokenType.fontWeight: 'FontWeight',
  };

  /// Types that need no Flutter import.
  static const Set<TokenType> core = {
    TokenType.number,
    TokenType.string,
    TokenType.boolean,
    TokenType.duration,
  };
}
