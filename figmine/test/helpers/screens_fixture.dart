import 'figma_nodes.dart';

Map<String, Object?> _button(String id, int fill, int label) => box(
  id,
  type: 'INSTANCE',
  componentId: 'C:btn',
  fill: fill,
  radius: 8,
  width: 160,
  height: 48,
  padding: 12,
  paddingX: 24,
  gap: 8,
  children: [text('Continue', label, size: 14, weight: 600)],
);

Map<String, Object?> _home(String id, {required bool dark}) {
  final ink = dark ? 0xF2F2F2 : 0x1A1A1A;
  final body = 'Plan your next trip with offers picked for you. ' * 4;
  return box(
    id,
    name: dark ? 'Home dark' : 'Home',
    fill: dark ? 0x121212 : 0xFFFFFF,
    width: 375,
    height: 812,
    children: [
      box(
        '$id:bar',
        type: 'INSTANCE',
        componentId: 'C:bar',
        fill: 0xF5F5F5,
        width: 375,
        height: 64,
      ),
      text('Welcome back', ink, size: 24, weight: 700, lineHeight: 32),
      text(body, ink, lineHeight: 24),
      text('Updated today', 0x6B6B6B, size: 12),
      box(
        '$id:card',
        type: 'INSTANCE',
        componentId: 'C:card',
        fill: 0xF5F5F5,
        width: 343,
        height: 120,
        radius: 16,
        padding: 16,
        gap: 8,
        shadow: 8,
      ),
      _button('$id:b1', dark ? 0x8AA7FF : 0x3567F6, dark ? 0x000000 : 0xFFFFFF),
      _button('$id:b2', dark ? 0x8AA7FF : 0x3567F6, dark ? 0x000000 : 0xFFFFFF),
      for (final n in [1, 2])
        box(
          '$id:in$n',
          type: 'INSTANCE',
          componentId: 'C:input',
          fill: dark ? null : 0xFFFFFF,
          stroke: 0x8A8A8A,
          width: 343,
          height: 56,
          radius: 4,
        ),
      for (final n in [1, 2])
        box(
          '$id:chip$n',
          type: 'INSTANCE',
          componentId: 'C:chip',
          fill: 0xE8E7EF,
          width: 80,
          height: 32,
          radius: 16,
        ),
      box('$id:line', stroke: 0xE0E0E0, width: 343, height: 1),
      if (!dark) text('Required', 0xD40E14, size: 12),
    ],
  );
}

/// `GET /v1/files/:key/nodes?ids=1:1,1:2` with component metadata.
final Map<String, Object?> screenNodesJson = {
  'nodes': {
    for (final (id, dark) in [('1:1', false), ('1:2', true)])
      id: {
        'document': _home(id, dark: dark),
        'components': {
          'C:btn': {'name': 'Type=Primary', 'componentSetId': 'S:btn'},
          'C:bar': {'name': 'App Bar'},
          'C:card': {'name': 'Offer card'},
          'C:input': {'name': 'Text field'},
          'C:chip': {'name': 'Chip'},
        },
        'componentSets': {
          'S:btn': {'name': 'Button'},
        },
        'styles': <String, Object?>{},
      },
  },
};
