import 'package:figmine/src/cli/file_offer.dart';
import 'package:figmine/src/cli/init_prompt.dart';
import 'package:figmine/src/config/file_key.dart';

/// The choices of an interactive `figmine init`.
typedef InitAnswers = ({
  String key,
  String source,
  bool screens,
  bool workflows,
  String prefix,
});

/// Asks for the file and the settings, suggesting what the file offers.
abstract final class InitWizard {
  /// Runs the questions on [prompt]. [probe] reads what a file offers, or
  /// is null without a Figma token.
  static Future<InitAnswers> ask(
    InitPrompt prompt,
    Future<FileOffer> Function(String key)? probe,
  ) async {
    var key = '';
    for (var tries = 0; key.isEmpty; tries++) {
      if (tries == 5) throw const FormatException('No Figma file given.');
      key = FileKey.parse(prompt.text('Figma file URL or key', ''));
      final problem = key.isEmpty ? 'Enter a file.' : FileKey.problem(key);
      if (problem != null) prompt.write('$problem\n');
      if (problem != null) key = '';
    }
    final offer = await probe?.call(key);
    if (offer != null) prompt.write('${_describe(offer)}\n');
    final variables = (offer?.variables ?? 0) > 0;
    final sources = [
      if (variables || offer == null) ('variables', 'Figma Variables'),
      ('file', 'The exporter plugin, design-tokens.json in the project'),
      ('auto', 'Styles, and what the designed screens show'),
    ];
    final picked = prompt.choice('Where should the tokens come from?', [
      for (final (_, label) in sources) label,
    ]);
    return (
      key: key,
      source: sources[picked].$1,
      screens: prompt.yes(
        'Also read colors, type and components from the screens?',
        fallback: true,
      ),
      workflows: prompt.yes('Add the GitHub workflows?', fallback: true),
      prefix: prompt.text('Class prefix', 'App'),
    );
  }

  static String _describe(FileOffer offer) {
    final name = offer.name == null ? 'The file' : '"${offer.name}"';
    final variables = offer.variables == null
        ? 'its variables are not readable with this token, so the exporter '
              'plugin is the way to get them'
        : 'it has ${offer.variables} variables';
    final styles = offer.styles == null ? '' : ' and ${offer.styles} styles';
    return '$name: $variables$styles.';
  }
}
