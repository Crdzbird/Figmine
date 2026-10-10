/// A Figma color object for [rgb], such as `0x3567F6`.
Map<String, Object?> rgb(int rgb) => {
  'r': (rgb >> 16 & 0xFF) / 255,
  'g': (rgb >> 8 & 0xFF) / 255,
  'b': (rgb & 0xFF) / 255,
  'a': 1,
};

List<Object?> _solid(int? color) => [
  if (color != null) {'type': 'SOLID', 'color': rgb(color)},
];

/// A frame or instance node.
Map<String, Object?> box(
  String id, {
  String type = 'FRAME',
  String name = 'Frame',
  int? fill,
  int? stroke,
  double width = 100,
  double height = 40,
  double? radius,
  double? padding,
  double? paddingX,
  double? gap,
  double? shadow,
  String? componentId,
  List<Object?> children = const [],
}) => {
  'id': id,
  'type': type,
  'name': name,
  'componentId': ?componentId,
  'fills': _solid(fill),
  'strokes': _solid(stroke),
  'strokeWeight': stroke == null ? 0 : 1,
  'absoluteBoundingBox': {'width': width, 'height': height},
  'cornerRadius': ?radius,
  if (padding != null || paddingX != null || gap != null) ...{
    'layoutMode': 'VERTICAL',
    'paddingLeft': paddingX ?? padding ?? 0,
    'paddingRight': paddingX ?? padding ?? 0,
    'paddingTop': padding ?? 0,
    'paddingBottom': padding ?? 0,
    'itemSpacing': gap ?? 0,
  },
  if (shadow != null)
    'effects': [
      {'type': 'DROP_SHADOW', 'radius': shadow},
    ],
  'children': children,
};

/// A TEXT node.
Map<String, Object?> text(
  String characters,
  int color, {
  double size = 16,
  int weight = 400,
  double? lineHeight,
}) => {
  'type': 'TEXT',
  'name': characters,
  'characters': characters,
  'fills': _solid(color),
  'style': {
    'fontFamily': 'Inter',
    'fontSize': size,
    'fontWeight': weight,
    'lineHeightPx': ?lineHeight,
  },
};
