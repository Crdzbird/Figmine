import 'package:figmine/src/config/tokens_config.dart';
import 'package:figmine/src/inference/color/surface_roles.dart';
import 'package:figmine/src/inference/design_inference.dart';
import 'package:figmine/src/screens/screen_set.dart';
import 'package:figmine/src/tokens/color_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/figma_nodes.dart';

Map<String, Object?> _screen(int i, {List<Object?> extra = const []}) => box(
  's$i',
  width: 400,
  height: 800,
  fill: 0xFFFFFF,
  children: [
    box('panel$i', width: 400, height: 500, fill: 0xF5F5F5),
    for (var b = 0; b < 2; b++)
      box(
        'b$i$b',
        type: 'INSTANCE',
        componentId: 'primary',
        fill: 0x2C2C2C,
        radius: 8,
        children: [text('Go', 0xF5F5F5)],
      ),
    box('tint$i', width: 80, fill: 0xEBFFEE),
    text('Body copy for the screen', 0x1E1E1E),
    ...extra,
  ],
);

int? _role(Map<String, int?> roles, String name) => roles[name];

void main() {
  final result = DesignInference.analyze(
    ScreenSet(
      frames: [
        for (var i = 0; i < 4; i++)
          (
            page: 'Screens',
            node: _screen(
              i,
              extra: [
                if (i == 0) box('note', width: 60, height: 20, fill: 0x8A226F),
              ],
            ),
          ),
      ],
      components: {
        'primary': {'name': 'Button variant=Primary, state=Default'},
      },
    ),
    const TokensConfig(),
  );
  final roles = {
    for (final t in result.colors!.tokens)
      t.name: (t.values.values.first.value as ColorValue).argb,
  };

  test('a gray default button gives a gray primary', () {
    expect(_role(roles, 'primary'), 0xFF2C2C2C);
    expect(_role(roles, 'onPrimary'), 0xFFF5F5F5);
  });

  test('the surface is the lightest major background', () {
    expect(_role(roles, 'surface'), 0xFFFFFFFF);
    expect(_role(roles, 'surfaceContainerLow'), 0xFFF5F5F5);
  });

  test('pale tints are not neutral and never become containers', () {
    expect(SurfaceRoles.isNeutral(0xFFEBFFEE), isFalse);
    expect(SurfaceRoles.isNeutral(0xFFF5F5F5), isTrue);
    expect(roles.values, isNot(contains(0xFFEBFFEE)));
  });

  test('an accent seen on a single screen is not a theme color', () {
    expect(roles.values, isNot(contains(0xFF8A226F)));
  });
}
