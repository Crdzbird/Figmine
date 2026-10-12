import 'package:figmine/figmine.dart';
import 'package:figmine_example/app/component_section.dart';
import 'package:figmine_example/app/example_app.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(ExampleApp(mode: ValueNotifier(ThemeMode.light)));
    await tester.tap(find.text('Components'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Snack bar'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(ComponentSection),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }

  testWidgets('surfaces use the generated themes', (tester) async {
    await open(tester);
    final theme = Theme.of(tester.element(find.text('Snack bar')));
    expect(
      theme.dialogTheme.backgroundColor,
      AppColorScheme.light.dialog.color,
    );
    expect(
      theme.snackBarTheme.backgroundColor,
      AppColorScheme.light.snackbar.color,
    );
    expect(
      theme.floatingActionButtonTheme.sizeConstraints?.maxWidth,
      AppComponents.fabSize,
    );
    expect(theme.navigationBarTheme.height, AppComponents.navigationBarHeight);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('opens a dialog, a sheet and a snack bar', (tester) async {
    await open(tester);
    await tester.tap(find.text('Dialog'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Bottom sheet'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Snack bar'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('the tokens tab shows every catalogue', (tester) async {
    await tester.pumpWidget(ExampleApp(mode: ValueNotifier(ThemeMode.light)));
    await tester.tap(find.text('Tokens'));
    await tester.pumpAndSettle();
    expect(find.byType(FigmineGallery), findsOneWidget);
    expect(find.text('Primitives'), findsOneWidget);
  });
}
