import 'package:figmine/figmine.dart';
import 'package:figmine_example/app/color_section.dart';
import 'package:figmine_example/app/component_section.dart';
import 'package:figmine_example/app/effects_section.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Shows the generated colors, components, effects and type, with page
/// spacing that follows the window size.
final class TokenGalleryPage extends StatelessWidget {
  /// Creates the page.
  const factory({required ValueNotifier<ThemeMode> mode, Key? key}) =
      TokenGalleryPage._;

  const new _({required this.mode, super.key});

  /// Current light or dark selection.
  final ValueNotifier<ThemeMode> mode;

  @override
  Widget build(BuildContext context) {
    final isDark = context.appColorScheme.brightness == Brightness.dark;
    final padding = EdgeInsets.all(context.appSpacing.pageMargin);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('figmine tokens'),
          actions: [
            IconButton(
              tooltip: 'Toggle theme',
              icon: const FigmineIcon(AppIcons.arrowDirectionLeft),
              onPressed: () =>
                  mode.value = isDark ? ThemeMode.light : ThemeMode.dark,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Colors'),
              Tab(text: 'Components'),
              Tab(text: 'Effects'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ColorSection(padding: padding),
            ComponentSection(padding: padding),
            EffectsSection(padding: padding),
          ],
        ),
      ),
    );
  }
}
