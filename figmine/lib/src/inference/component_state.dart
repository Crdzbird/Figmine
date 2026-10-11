/// Interaction states of a component variant.
enum ComponentState {
  /// The resting state.
  enabled,

  /// The pointer is over it.
  hovered,

  /// It is being pressed.
  pressed,

  /// It has keyboard focus.
  focused,

  /// It does not accept input.
  disabled,

  /// It shows a validation error.
  error,

  /// It is selected or checked.
  selected;

  static final RegExp _pair = RegExp(r'([a-z][a-z ]*?)\s*=\s*([a-z0-9-]+)');

  static final RegExp _stateKey = RegExp(
    r'(^|\s)(state|status|interaction)s?$',
  );

  static final RegExp _yes = RegExp(r'^(true|yes|on)$');

  static final RegExp _checked = RegExp(r'^(checked|selected|on)$');

  static final RegExp _mixed = RegExp(r'^(indeterminate|mixed|partial)$');

  static final Map<ComponentState, RegExp> _words = {
    hovered: RegExp(r'^hover(ed)?$'),
    pressed: RegExp(r'^(press(ed)?|down|clicked)$'),
    focused: RegExp(r'^focus(ed|-visible)?$'),
    disabled: RegExp(r'^(disabled|inactive)$'),
    error: RegExp(r'^(error|invalid|danger)$'),
    selected: RegExp(r'^(selected|checked|active)$'),
  };

  /// Whether a variant [name] names a state or a selection at all, such
  /// as `state=enabled` or `selected=false`, unlike a plain container.
  static bool stated(String name) =>
      _pair.allMatches(name.toLowerCase()).any((m) {
        final key = m.group(1)!.trim();
        return _stateKey.hasMatch(key) ||
            _flag.hasMatch(key) ||
            _checked.hasMatch(m.group(2)!);
      });

  static final RegExp _flag = RegExp(
    r'(^|\s)(selected|checked|active|disabled|error)$',
  );

  /// The state a variant [name] describes, such as `state=hover`,
  /// `error=yes`, `type=error` or `Value Type=Checked`, or null when it
  /// names several, such as a focused error, or a mixed one, such as
  /// indeterminate.
  static ComponentState? of(String name) {
    final found = <ComponentState>{};
    for (final match in _pair.allMatches(name.toLowerCase())) {
      final key = match.group(1)!.trim();
      final value = match.group(2)!;
      if (_mixed.hasMatch(value)) return null;
      if (_checked.hasMatch(value)) found.add(selected);
      if (!_stateKey.hasMatch(key)) {
        for (final state in const [error, disabled]) {
          if (_words[state]!.hasMatch(value)) found.add(state);
        }
      }
      final word = _stateKey.hasMatch(key)
          ? value
          : (_yes.hasMatch(value) ? key.split(' ').last : null);
      if (word == null) continue;
      for (final entry in _words.entries) {
        if (entry.value.hasMatch(word)) found.add(entry.key);
      }
    }
    if (found.length > 1) return null;
    return found.firstOrNull ?? enabled;
  }
}
