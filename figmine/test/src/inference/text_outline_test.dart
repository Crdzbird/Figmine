import 'package:figmine/src/inference/component_kind.dart';
import 'package:figmine/src/inference/inferred_color.dart';
import 'package:figmine/src/inference/outline_roles.dart';
import 'package:figmine/src/inference/surface_roles.dart';
import 'package:figmine/src/inference/usage_stats.dart';
import 'package:flutter_test/flutter_test.dart';

UsageStats _stats({
  Map<int, int> texts = const {},
  Map<int, int> strokes = const {},
  int? field,
}) {
  final s = UsageStats()
    ..frames = 1
    ..totalArea = 1000
    ..backgroundArea[0xFFFFFFFF] = 1000;
  s.textCharacters.addAll(texts);
  s.strokes.addAll(strokes);
  for (var i = 0; i < 3 && field != null; i++) {
    s.samples.add((
      kind: ComponentKind.input,
      name: 'text field',
      instance: true,
      definition: false,
      family: 'text field',
      fill: null,
      fillVariable: null,
      stroke: field,
      strokeVariable: null,
      label: 0xFF1D1B20,
      labelVariable: null,
      radius: 4,
      pill: false,
      height: 56,
      paddingHorizontal: 16,
      padding: null,
      shadow: 0,
      mark: null,
      markVariable: null,
    ));
  }
  return s;
}

void main() {
  test('body text has the most contrast among the main text colors', () {
    final roles = <String, InferredColor>{};
    SurfaceRoles.infer(
      roles,
      _stats(texts: {0xFF49454F: 24876, 0xFF1D1B20: 22975, 0xFF6750A4: 3033}),
    );
    expect(roles['onSurface']!.argb, 0xFF1D1B20);
    expect(roles['onSurfaceVariant']!.argb, 0xFF49454F);
  });

  test('text fields set the outline when dividers dominate strokes', () {
    Map<String, InferredColor> outline(UsageStats s) {
      final roles = <String, InferredColor>{};
      OutlineRoles.infer(roles, s, 0xFFFFFFFF);
      return roles;
    }

    final pale = {0xFFCAC4D0: 917, 0xFF79747E: 242};
    final m3 = outline(_stats(strokes: pale, field: 0xFF79747E));
    expect(m3['outline']!.argb, 0xFF79747E);
    expect(m3['outlineVariant']!.argb, 0xFFCAC4D0);
    expect(outline(_stats(strokes: pale))['outline']!.argb, 0xFFCAC4D0);
    final strong = {0xFF9D9D9D: 943, 0xFF787878: 346};
    expect(
      outline(_stats(strokes: strong, field: 0xFF787878))['outline']!.argb,
      0xFF9D9D9D,
    );
  });
}
