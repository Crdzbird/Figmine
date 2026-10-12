import 'package:figmine/src/cli/init/file_offer.dart';
import 'package:figmine/src/cli/init/init_prompt.dart';
import 'package:figmine/src/cli/init/init_wizard.dart';
import 'package:figmine/src/cli/templates/config_template.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/inference_mode.dart';
import 'package:figmine/src/config/token_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

(InitPrompt, StringBuffer) _prompt(List<String> lines) {
  final out = StringBuffer();
  final queue = [...lines];
  return (
    InitPrompt(
      read: () => queue.isEmpty ? null : queue.removeAt(0),
      write: out.write,
    ),
    out,
  );
}

void main() {
  const url = 'https://www.figma.com/design/AbC123xyzAbC/My-App';

  test('without readable variables, the plugin is offered first', () async {
    final (prompt, out) = _prompt(['figd_secret', url, '1', 'n', '', 'Brand']);
    final answers = await InitWizard.ask(
      prompt,
      (key) async => (name: 'My App', variables: null, styles: 4),
    );
    expect(answers.key, 'AbC123xyzAbC');
    expect(answers.source, 'file');
    expect((answers.screens, answers.workflows), (false, true));
    expect(answers.prefix, 'Brand');
    expect('$out', contains('looks like a Figma access token'));
    expect('$out', isNot(contains('figd_secret')));
    expect('$out', contains('"My App": its variables are not readable'));
  });

  test('the answers become a valid configuration', () {
    final yaml = ConfigTemplate.render(
      'AbC123xyzAbC',
      source: 'file',
      inference: 'off',
      prefix: 'Brand',
    );
    final config = FigmineConfig.fromYaml(loadYaml(yaml) as Map);
    expect(config.tokens.source, TokenSource.file);
    expect(config.tokens.files, ['design-tokens.json']);
    expect(config.inference.mode, InferenceMode.off);
    expect(config.output.classPrefix, 'Brand');
  });

  test('a closed terminal stops asking', () async {
    final (prompt, _) = _prompt([]);
    const FileOffer offer = (name: null, variables: 3, styles: null);
    await expectLater(
      InitWizard.ask(prompt, (key) async => offer),
      throwsFormatException,
    );
  });
}
