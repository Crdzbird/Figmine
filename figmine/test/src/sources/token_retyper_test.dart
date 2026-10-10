import 'package:figmine/src/codegen/dart_source.dart';
import 'package:figmine/src/sources/dtcg/dtcg_types.dart';
import 'package:figmine/src/sources/token_retyper.dart';
import 'package:figmine/src/tokens/curve_value.dart';
import 'package:figmine/src/tokens/design_token.dart';
import 'package:figmine/src/tokens/duration_value.dart';
import 'package:figmine/src/tokens/token_collection.dart';
import 'package:figmine/src/tokens/token_ref.dart';
import 'package:figmine/src/tokens/token_type.dart';
import 'package:figmine/src/tokens/token_value.dart';
import 'package:flutter_test/flutter_test.dart';

DesignToken _token(String name, TokenType type, Object value, [String? to]) =>
    DesignToken(
      path: name.split('/'),
      type: type,
      values: {
        'Value': TokenValue(
          value,
          alias: to == null
              ? null
              : TokenRef(collection: 'Motion', path: to.split('/')),
        ),
      },
    );

void main() {
  test('names and values retype whole alias groups', () {
    final [motion] = TokenRetyper.apply([
      TokenCollection(
        name: 'Motion',
        modes: const ['Value'],
        tokens: [
          _token('duration/short', TokenType.number, 150.0),
          _token('transition/fast', TokenType.number, 150.0, 'duration/short'),
          _token('easing/standard', TokenType.string, 'cubic-bezier(.2,0,0,1)'),
          _token('font/weight/bold', TokenType.number, 700.0),
          _token('border/weight', TokenType.number, 1.0),
          _token('font/weight/odd', TokenType.number, 1.5),
          _token('label', TokenType.string, 'Hello'),
        ],
      ),
    ]);
    expect(
      {for (final t in motion.tokens) t.name: t.type},
      {
        'duration/short': TokenType.duration,
        'transition/fast': TokenType.duration,
        'easing/standard': TokenType.curve,
        'font/weight/bold': TokenType.fontWeight,
        'border/weight': TokenType.number,
        'font/weight/odd': TokenType.number,
        'label': TokenType.string,
      },
    );
    final fast = motion.find('transition/fast')!.values['Value']!;
    expect(fast.alias?.label, 'duration/short (Motion)');
    expect(DartSource.value(fast.value), 'Duration(milliseconds: 150)');
  });

  test('DTCG motion, weight and boolean types become Dart values', () {
    Object? parse(String type, Object raw) =>
        DtcgTypes.parse(DtcgTypes.of(type), raw);
    expect(DartSource.value(parse('duration', '0.25s')!), contains('250'));
    expect(
      DartSource.value(parse('cubicBezier', [0.4, 0, 1, 1])!),
      'Cubic(0.4, 0, 1, 1)',
    );
    expect(
      DartSource.value(parse('fontWeight', 'semibold')!),
      'FontWeight.w600',
    );
    expect(DartSource.value(parse('fontWeight', 450)!), 'FontWeight(450)');
    expect(parse('boolean', false), isFalse);
    expect(
      DurationValue.tryParse({'value': 2, 'unit': 's'})?.milliseconds,
      2000,
    );
    expect(CurveValue.tryParse('ease'), isNull);
  });
}
