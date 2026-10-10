import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';

/// A named token with one value per mode of its collection.
final class DesignToken {
  /// Creates a token.
  const factory({
    required List<String> path,
    required TokenType type,
    required Map<String, TokenValue> values,
    String description,
    String? variableId,
  }) = DesignToken._;

  const new _({
    required this.path,
    required this.type,
    required this.values,
    this.description = '',
    this.variableId,
  });

  /// Name segments, for example `['palette', 'blue', '500']`.
  final List<String> path;

  /// The kind of value.
  final TokenType type;

  /// Values keyed by mode name.
  final Map<String, TokenValue> values;

  /// Description written in Figma.
  final String description;

  /// Figma variable id, when known, used to match screen bindings.
  final String? variableId;

  /// The token name joined with `/`.
  String get name => path.join('/');

  /// Segments above the last one, which name the generated class.
  List<String> get group => path.sublist(0, path.length - 1);

  /// The last segment, which names the generated constant.
  String get leaf => path.last;
}
