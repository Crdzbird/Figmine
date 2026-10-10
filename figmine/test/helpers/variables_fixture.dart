Map<String, Object?> _color(double r, double g, double b) => {
  'r': r,
  'g': g,
  'b': b,
  'a': 1,
};

Map<String, Object?> _alias(String id) => {'type': 'VARIABLE_ALIAS', 'id': id};

Map<String, Object?> _variable(
  String name,
  String collection,
  Map<String, Object?> values, {
  String type = 'COLOR',
  bool remote = false,
  String description = '',
}) => {
  'name': name,
  'variableCollectionId': collection,
  'resolvedType': type,
  'remote': remote,
  'description': description,
  'valuesByMode': values,
};

/// Response of `GET /v1/files/:key/variables/local`.
///
/// `Primitives` has one mode, `Semantic` has Light and Dark and aliases
/// the primitives.
final Map<String, Object?> variablesJson = {
  'status': 200,
  'error': false,
  'meta': {
    'variableCollections': {
      'VC:prim': {
        'name': 'Primitives',
        'defaultModeId': 'p1',
        'modes': [
          {'modeId': 'p1', 'name': 'Value'},
        ],
      },
      'VC:sem': {
        'name': 'Semantic',
        'defaultModeId': 'm1',
        'modes': [
          {'modeId': 'm2', 'name': 'Dark'},
          {'modeId': 'm1', 'name': 'Light'},
        ],
      },
    },
    'variables': {
      'V:blue': _variable('palette/blue/500', 'VC:prim', {
        'p1': _color(0, 0, 1),
      }, description: 'Brand blue [500].'),
      'V:white': _variable('palette/white', 'VC:prim', {'p1': _color(1, 1, 1)}),
      'V:black': _variable('palette/black', 'VC:prim', {'p1': _color(0, 0, 0)}),
      'V:radius': _variable('radius/16', 'VC:prim', {'p1': 16}, type: 'FLOAT'),
      'V:font': _variable('font/family', 'VC:prim', {
        'p1': 'Inter',
      }, type: 'STRING'),
      'V:primary': _variable('color/primary', 'VC:sem', {
        'm1': _alias('V:blue'),
        'm2': _color(0.5, 0.5, 1),
      }),
      'V:onPrimary': _variable('color/on-primary', 'VC:sem', {
        'm1': _alias('V:white'),
        'm2': _alias('V:black'),
      }),
      'V:success': _variable('color/success', 'VC:sem', {
        'm1': _color(0, 0.5, 0),
        'm2': _color(0, 1, 0),
      }),
      'V:flag': _variable('flag', 'VC:sem', {'m1': true}, type: 'BOOLEAN'),
      'V:remote': _variable('lib/red', 'VC:sem', {
        'm1': _color(1, 0, 0),
      }, remote: true),
    },
  },
};
