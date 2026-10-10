import 'package:figmine/figmine.dart';
import 'package:figmine_example/app/component_section.dart';
import 'package:figmine_example/app/example_app.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('applies the scaffolded theme and toggles mode', (tester) async {
    final mode = ValueNotifier(ThemeMode.light);
    await tester.pumpWidget(ExampleApp(mode: mode));
    final context = tester.element(find.text('figmine tokens'));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, AppSemanticLight.primary);
    expect(theme.extension<AppColorScheme>(), AppColorScheme.light);
    expect(context.appColorScheme.success, AppSemanticLight.success);
    expect(theme.textTheme.displayLarge?.fontSize, 57);
    final button = theme.filledButtonTheme.style!;
    expect(button.minimumSize?.resolve({})?.height, AppComponents.buttonHeight);
    expect(
      theme.checkboxTheme.fillColor?.resolve({WidgetState.selected}),
      AppSemanticLight.primary,
    );

    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();
    expect(mode.value, ThemeMode.dark);
    final dark = tester.element(find.text('figmine tokens'));
    expect(Theme.of(dark).colorScheme.primary, AppSemanticDark.primary);
    expect(dark.appColorScheme.brightness, Brightness.dark);
  });

  testWidgets('spacing follows the window size', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final (width, modes) in [
      (400.0, AppSpacingModes.mobile),
      (700.0, AppSpacingModes.tablet),
      (1200.0, AppSpacingModes.desktop),
    ]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(ExampleApp(mode: ValueNotifier(ThemeMode.light)));
      final context = tester.element(find.text('figmine tokens'));
      expect(context.appSpacing, modes);
    }
    expect(AppSpacingModes.byMode('Tablet').pageMargin, 24);
  });

  testWidgets('shows components, effects and icons', (tester) async {
    await tester.pumpWidget(ExampleApp(mode: ValueNotifier(ThemeMode.light)));
    await tester.tap(find.text('Components'));
    await tester.pumpAndSettle();
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byWidgetPredicate(
        (w) => w is FigmineIcon && w.size == 32 && w.asset == AppIcons.home,
      ),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ComponentSection),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(
      find.byWidgetPredicate((w) => w is FigmineIcon && w.size == 32),
      findsNWidgets(AppIcons.values.length),
    );

    await tester.tap(find.text('Effects'));
    await tester.pumpAndSettle();
    final shadow = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('shadow')),
    );
    expect(
      (shadow.decoration as BoxDecoration).boxShadow,
      AppEffectsElevation.v1,
    );
    expect(find.text('Display large'), findsOneWidget);
  });

  test('catalogues list every token with its mode', () {
    expect(appSemanticColorTokens.where((t) => t.mode == 'Dark'), hasLength(7));
    expect(appPrimitivesNumberTokens.single.value, 16);
    expect(appPrimitivesStringTokens.single.value, 'Inter');
    expect(appSpacingNumberTokens, hasLength(9));
    expect(appEffectsGradientTokens.single.value, AppEffectsGradient.brand);
    expect(AppMotionTransition.fast, const Duration(milliseconds: 150));
    expect(AppMotionEasing.standard, const Cubic(0.2, 0, 0, 1));
    expect(AppPrimitivesFontWeight.bold, FontWeight.w700);
    expect(AppFlags.newCheckout, isTrue);
  });
}
