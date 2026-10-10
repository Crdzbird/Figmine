import 'package:figmine/src/inference/state_paints.dart';

/// What the screens tell about colors beyond the tokens themselves: the
/// variables bound to each role, how often each color is used, and the
/// colors of component states, keyed like `button.hovered.fill`.
typedef ScreenEvidence = ({
  Map<String, String> roleVariables,
  Map<int, int> colorUses,
  Map<String, StatePaint> componentColors,
});

/// Evidence when no screens were analyzed.
const ScreenEvidence noEvidence = (
  roleVariables: {},
  colorUses: {},
  componentColors: {},
);
