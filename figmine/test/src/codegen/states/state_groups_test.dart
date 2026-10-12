import 'package:figmine/src/codegen/emit/code_emitter.dart';
import 'package:figmine/src/codegen/states/state_field_specs.dart';
import 'package:figmine/src/codegen/states/state_groups.dart';
import 'package:figmine/src/config/figmine_config.dart';
import 'package:figmine/src/config/project_info.dart';
import 'package:figmine/src/score/scheme_values.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/sample_tokens.dart';

void main() {
  test('every state field has a member and comes back from it', () {
    for (final spec in StateFieldSpecs.all) {
      final kind = StateGroups.kindOf(spec.name)!;
      final member = StateGroups.member(spec.name, kind);
      expect(StateGroups.field(kind, member), spec.name);
    }
    expect(StateGroups.member('buttonHovered', 'button'), 'hovered');
    expect(StateGroups.member('onButton', 'button'), 'onColor');
    expect(
      StateGroups.member('inputFocusedOutline', 'input'),
      'focusedOutline',
    );
    expect(StateGroups.accessor('switch'), 'toggle');
    expect(StateGroups.kindOf('primary'), isNull);
  });

  test('the scheme holds a group per component, read back flat', () {
    final files = {
      for (final f in CodeEmitter.emit(
        config: const FigmineConfig(fileKey: 'KEY'),
        tokens: sampleTokens,
        project: const ProjectInfo(modernConstructors: true),
      ))
        f.path.replaceFirst('lib/theme/tokens/', ''): f.contents,
    };
    final scheme = files['color/color_scheme.g.dart']!;
    expect(scheme, contains('final AppButtonColors button;'));
    expect(scheme, contains('final AppSwitchColors toggle;'));
    expect(scheme, contains('button: AppButtonColors.light,'));
    expect(scheme, isNot(contains('buttonHovered')));
    final groups = {
      for (final e in files.entries)
        if (e.key.startsWith('color/states/'))
          RegExp(r'final class (\w+)').firstMatch(e.value)!.group(1)!: e.value,
    };
    final light = SchemeValues.read(
      scheme,
      'AppColorScheme',
      const {},
      'light',
      groups: groups,
    );
    expect(light.keys, containsAll(['buttonHovered', 'onButton', 'tooltip']));
    final toggle = SchemeValues.read(
      '  static const AppColorScheme light = AppColorScheme(\n'
          '    toggle: AppSwitchColors.light,\n'
          '  );',
      'AppColorScheme',
      const {},
      'light',
      groups: {
        'AppSwitchColors':
            '  static const AppSwitchColors light = AppSwitchColors(\n'
            '    trackSelected: Color(0xFF6750A4),\n'
            '  );',
      },
    );
    expect(toggle, {'switchTrackSelected': 0xFF6750A4});
  });
}
