/// Response of `GET /v1/files/:key` with color and text styles.
const Map<String, Object?> fileJson = {
  'name': 'Design System',
  'styles': {
    'S:1': {'name': 'Light/primary', 'styleType': 'FILL'},
    'S:2': {'name': 'Dark/primary', 'styleType': 'FILL'},
    'S:3': {'name': 'brand/accent', 'styleType': 'FILL'},
    'S:4': {'name': 'Display/Large', 'styleType': 'TEXT'},
    'S:5': {'name': 'body', 'styleType': 'TEXT'},
    'S:6': {'name': 'Shadow', 'styleType': 'EFFECT'},
  },
};

Map<String, Object?> _fill(List<Object?> fills) => {
  'document': {'fills': fills},
};

Map<String, Object?> _text(Map<String, Object?> style) => {
  'document': {'type': 'TEXT', 'style': style},
};

/// Response of `GET /v1/files/:key/nodes` for the style nodes.
final Map<String, Object?> styleNodesJson = {
  'nodes': {
    'S:1': _fill([
      {
        'type': 'SOLID',
        'color': {'r': 1, 'g': 0, 'b': 0, 'a': 1},
      },
    ]),
    'S:2': _fill([
      {
        'type': 'SOLID',
        'opacity': 0.5,
        'color': {'r': 0.5, 'g': 0, 'b': 0, 'a': 1},
      },
    ]),
    'S:3': _fill([
      {'type': 'GRADIENT_LINEAR'},
      {
        'type': 'SOLID',
        'visible': false,
        'color': {'r': 1, 'g': 1, 'b': 1, 'a': 1},
      },
      {
        'type': 'SOLID',
        'color': {'r': 0, 'g': 1, 'b': 0, 'a': 1},
      },
    ]),
    'S:4': _text({
      'fontFamily': 'Inter',
      'fontWeight': 700,
      'fontSize': 32,
      'lineHeightPx': 40,
      'letterSpacing': -0.25,
    }),
    'S:5': _text({
      'fontFamily': 'Inter',
      'fontWeight': 450,
      'fontSize': 16,
      'lineHeightPx': 24,
      'lineHeightUnit': 'INTRINSIC_%',
      'italic': true,
      'textDecoration': 'UNDERLINE',
    }),
  },
};
