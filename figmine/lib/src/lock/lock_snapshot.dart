import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:figmine/src/tokens/gradient_value.dart';
import 'package:figmine/src/tokens/shadow_value.dart';
import 'package:figmine/src/tokens/text_style_token.dart';
import 'package:figmine/src/tokens/token_set.dart';

/// Flattens a [TokenSet] into comparable strings for the lock file.
abstract final class LockSnapshot {
  /// Tokens keyed by `collection/path`, values joined per mode.
  static Map<String, String> tokens(TokenSet set) => {
    for (final collection in set.collections)
      for (final token in collection.tokens)
        '${collection.name}/${token.name}': [
          for (final entry in token.values.entries)
            _prefix(collection.multiMode, entry.key) +
                _value(entry.value.value),
        ].join(' '),
  };

  /// Component dimensions keyed by name.
  static Map<String, String> components(TokenSet set) => {
    for (final entry in set.components.entries)
      entry.key: DartSource.number(entry.value.value),
  };

  /// Text styles keyed by name.
  static Map<String, String> typography(TokenSet set) => {
    for (final style in set.textStyles) style.name: _style(style),
  };

  /// Icons keyed by name, valued by the SHA-256 of their SVG.
  static Map<String, String> icons(TokenSet set) => {
    for (final icon in set.icons)
      icon.name: sha256.convert(utf8.encode(icon.svg)).toString(),
  };

  static String _prefix(bool multiMode, String mode) =>
      multiMode ? '$mode=' : '';

  static String _value(Object value) => switch (value) {
    final ColorValue color => color.hex,
    final double number => DartSource.number(number),
    final ShadowValue _ || final GradientValue _ => DartSource.value(value),
    _ => '$value',
  };

  static String _style(TextStyleToken style) => [
    style.fontFamily,
    DartSource.number(style.fontSize),
    'w${style.fontWeight}',
    if (style.height case final height?) 'h${height.toStringAsFixed(3)}',
    if (style.letterSpacing case final spacing?)
      'ls${spacing.toStringAsFixed(2)}',
    if (style.italic) 'italic',
    ?style.decoration,
  ].join(' ');
}
