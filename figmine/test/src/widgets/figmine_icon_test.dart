import 'package:figmine/figmine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(FigmineIcon, () {
    testWidgets('follows the ambient IconTheme', (tester) async {
      await tester.pumpWidget(
        const IconTheme(
          data: IconThemeData(size: 32, color: Color(0xFF112233)),
          child: FigmineIcon('assets/home.svg'),
        ),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 32);
      expect(svg.height, 32);
      expect(
        svg.colorFilter,
        const ColorFilter.mode(Color(0xFF112233), BlendMode.srcIn),
      );
      expect(svg.excludeFromSemantics, isTrue);
    });

    testWidgets('explicit size, color and label win', (tester) async {
      await tester.pumpWidget(
        const FigmineIcon(
          'assets/home.svg',
          size: 12,
          color: Color(0xFFFF0000),
          semanticLabel: 'Home',
        ),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 12);
      expect(
        svg.colorFilter,
        const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn),
      );
      expect(svg.excludeFromSemantics, isFalse);
    });
  });
}
