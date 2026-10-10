import 'package:figmine/figmine.dart';
import 'package:figmine_example/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a dialog, a bottom sheet and a snack bar, shows a tooltip and a
/// navigation bar, all styled by the generated surface themes.
final class OverlayDemos extends StatelessWidget {
  /// Creates the demos.
  const factory({Key? key}) = OverlayDemos._;

  const new _({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = context.appSpacing.gutter;
    Future<void> dialog() async => await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dialog'),
        content: const Text('Styled by the dialog theme.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    Future<void> sheet() async => await showModalBottomSheet<void>(
      context: context,
      builder: (context) => const SizedBox(
        height: 160,
        child: Center(child: Text('Bottom sheet')),
      ),
    );
    void snack() =>
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Snack bar')));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            OutlinedButton(onPressed: dialog, child: const Text('Dialog')),
            OutlinedButton(onPressed: sheet, child: const Text('Sheet')),
            OutlinedButton(onPressed: snack, child: const Text('Snack bar')),
            const Tooltip(message: 'Tooltip', child: Text('Hover me')),
          ],
        ),
        SizedBox(height: gap),
        NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: FigmineIcon(AppIcons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: FigmineIcon(AppIcons.arrowDirectionLeft),
              label: 'Back',
            ),
          ],
        ),
      ],
    );
  }
}
