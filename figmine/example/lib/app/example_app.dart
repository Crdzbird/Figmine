import 'package:figmine_example/app/token_gallery_page.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// App themed by the scaffolded [AppTheme] over figmine generated tokens.
final class ExampleApp extends StatelessWidget {
  /// Creates the app with a switchable theme [mode].
  const factory({required ValueNotifier<ThemeMode> mode, Key? key}) =
      ExampleApp._;

  const new _({required this.mode, super.key});

  /// Current light or dark selection.
  final ValueNotifier<ThemeMode> mode;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: mode,
    builder: (context, value, _) => MaterialApp(
      title: 'figmine example',
      theme: const AppTheme().themeData,
      darkTheme: const AppTheme(brightness: Brightness.dark).themeData,
      themeMode: value,
      home: TokenGalleryPage(mode: mode),
    ),
  );
}
