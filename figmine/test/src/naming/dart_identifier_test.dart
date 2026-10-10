import 'package:figmine/src/naming/dart_identifier.dart';
import 'package:figmine/src/naming/unique_namer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(DartIdentifier, () {
    test('camel joins segments and keeps word boundaries', () {
      expect(
        DartIdentifier.camel(['brand', 'Primary Dark']),
        'brandPrimaryDark',
      );
      expect(DartIdentifier.camel(['on-primary']), 'onPrimary');
      expect(
        DartIdentifier.camel(['surfaceContainerHigh']),
        'surfaceContainerHigh',
      );
      expect(DartIdentifier.camel(['URL', 'icon']), 'urlIcon');
    });

    test('camel guards leading digits, keywords and empty names', () {
      expect(DartIdentifier.camel(['24', 'home']), 'v24Home');
      expect(DartIdentifier.camel(['default']), 'defaultToken');
      expect(DartIdentifier.camel(['light']), 'lightToken');
      expect(DartIdentifier.camel(['---']), 'unnamed');
    });

    test('pascal and snake', () {
      expect(DartIdentifier.pascal(['app', 'colors']), 'AppColors');
      expect(
        DartIdentifier.snake(['Arrow', 'Direction=Left']),
        'arrow_direction_left',
      );
      expect(DartIdentifier.snake(['AppColorTokens']), 'app_color_tokens');
    });
  });

  group(UniqueNamer, () {
    test('suffixes duplicates', () {
      final namer = UniqueNamer();
      expect(namer.claim('home'), 'home');
      expect(namer.claim('home'), 'home2');
      expect(namer.claim('home'), 'home3');
    });
  });
}
