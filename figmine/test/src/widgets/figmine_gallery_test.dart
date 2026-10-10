import 'package:figmine/figmine.dart';
import 'package:figmine/src/widgets/figmine_token_tile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const List<FigmineTokenEntry<Color>> _colors = [
  FigmineTokenEntry(
    collection: 'Semantic',
    path: 'primary',
    value: Color(0xFF3D5AFE),
    mode: 'Light',
    aliases: 'palette/blue/50 (Primitives)',
  ),
];

const List<FigmineTokenEntry<Duration>> _durations = [
  FigmineTokenEntry(
    collection: 'Motion',
    path: 'duration/short',
    value: Duration(milliseconds: 150),
  ),
];

const List<FigmineTokenEntry<Curve>> _curves = [
  FigmineTokenEntry(
    collection: 'Motion',
    path: 'easing/standard',
    value: Cubic(0.2, 0, 0, 1),
  ),
];

void main() {
  testWidgets('lists tokens under their collection with previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: FigmineGallery(catalog: [_colors, _durations, _curves]),
      ),
    );
    expect(find.text('Semantic'), findsOneWidget);
    expect(find.text('Motion'), findsOneWidget);
    expect(find.text('primary (Light)'), findsOneWidget);
    expect(
      find.text('#FF3D5AFE, from palette/blue/50 (Primitives)'),
      findsOneWidget,
    );
    expect(find.text('150 ms'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  test('values read as short text', () {
    expect(FigmineTokenTile.describe(16.0), '16');
    expect(FigmineTokenTile.describe(FontWeight.w600), 'w600');
    expect(FigmineTokenTile.describe(true), 'true');
    expect(
      FigmineTokenTile.describe(const Cubic(0.4, 0, 1, 1)),
      'Cubic(0.4, 0.0, 1.0, 1.0)',
    );
  });
}
