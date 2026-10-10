/// Components figmine measures to build component themes.
enum ComponentKind {
  /// Checkboxes.
  checkbox(r'\bcheck ?box(es)?\b', r'\bcheck ?box(es)?\b'),

  /// Radio buttons.
  radio(r'\bradio\b', r'\bradio\b'),

  /// Switches and toggles.
  toggle(r'\b(switch|toggle)(es)?\b', r'\b(switch|toggle)(es)?\b'),

  /// Tabs.
  tab(r'\btabs?\b', r'\btabs?\b'),

  /// Text fields, search bars, dropdowns.
  input(
    'input|text ?field|search ?(bar|field)|dropdown|select',
    'input|text ?field',
  ),

  /// App bars, headers and top navigation.
  appBar(
    'app ?bar|top ?bar|header|nav(igation)? ?bar|toolbar',
    'app ?bar|top ?bar|nav(igation)? ?bar|toolbar',
  ),

  /// Chips, tags and pills.
  chip(r'\b(chip|tag|pill)s?\b', r'\bchips?\b'),

  /// Cards and tiles.
  card(r'\b(card|tile)s?\b', r'\bcards?\b'),

  /// Buttons and calls to action.
  button(r'\b(button|btn|cta)s?\b', r'\bbuttons?\b');

  new(this.pattern, this.strong);

  /// Pattern matched against component, set and layer names.
  final String pattern;

  /// The part of [pattern] that names the kind outright, such as `chip`
  /// where `tag` may also be a badge.
  final String strong;

  /// The kind named in [name], or null.
  static ComponentKind? match(String name) {
    final lower = name.toLowerCase();
    for (final kind in values) {
      if (RegExp(kind.pattern).hasMatch(lower)) return kind;
    }
    return null;
  }
}
