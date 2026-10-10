import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/codegen/token_index.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// A Dart expression and the generated file it depends on.
typedef ValueExpression = ({String code, String? file});

/// Renders token values as references or literals.
abstract final class ValueExpressions {
  /// A reference to the aliased constant when it is generated, otherwise a
  /// literal.
  static ValueExpression of(TokenIndex index, TokenValue value) {
    final alias = value.alias;
    final target = alias == null
        ? null
        : index.find(alias.collection, alias.path.join('/'), alias.mode);
    if (target == null) {
      return (code: DartSource.value(value.value), file: null);
    }
    return (code: '${target.className}.${target.member}', file: target.file);
  }
}
