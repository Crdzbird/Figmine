const fs = require('fs');
const color = (r, g, b) => ({ r, g, b, a: 1 });
const collections = {
  'VC:core': { id: 'VC:core', name: '_core_colors', defaultModeId: 'c1', modes: [{ modeId: 'c1', name: 'Value' }], variableIds: ['V:blue', 'V:space'] },
  'VC:ui': { id: 'VC:ui', name: 'ui_colors', defaultModeId: 'l', modes: [{ modeId: 'd', name: 'Dark' }, { modeId: 'l', name: 'Light' }], variableIds: ['V:primary', 'V:lib', 'V:flag'] },
  'VC:lib': { id: 'VC:lib', name: 'Brand library', defaultModeId: 'b1', modes: [{ modeId: 'b1', name: 'Value' }], variableIds: [] },
};
const variables = {
  'V:blue': { id: 'V:blue', name: 'deep-blue/80', resolvedType: 'COLOR', variableCollectionId: 'VC:core', description: 'Raw deep-blue, stop 80.', valuesByMode: { c1: color(0.106, 0.067, 0.361) } },
  'V:space': { id: 'V:space', name: 'size/0.5', resolvedType: 'FLOAT', variableCollectionId: 'VC:core', description: '', valuesByMode: { c1: 2 } },
  'V:primary': { id: 'V:primary', name: 'text/static/regular', resolvedType: 'COLOR', variableCollectionId: 'VC:ui', description: 'Default body text colour.', valuesByMode: { l: { type: 'VARIABLE_ALIAS', id: 'V:blue' }, d: color(1, 1, 1) } },
  'V:lib': { id: 'V:lib', name: 'fills/brand', resolvedType: 'COLOR', variableCollectionId: 'VC:ui', description: '', valuesByMode: { l: { type: 'VARIABLE_ALIAS', id: 'V:remote' }, d: { type: 'VARIABLE_ALIAS', id: 'V:remote' } } },
  'V:remote': { id: 'V:remote', name: 'energy-blue/50', resolvedType: 'COLOR', variableCollectionId: 'VC:lib', description: '', valuesByMode: { b1: color(0.208, 0.404, 0.965) } },
  'V:flag': { id: 'V:flag', name: 'flag', resolvedType: 'BOOLEAN', variableCollectionId: 'VC:ui', valuesByMode: { l: true, d: false } },
};
let message;
global.__html__ = '';
global.figma = {
  root: { name: 'B2C Foundation Design System' },
  showUI: () => {},
  ui: { postMessage: (m) => { message = m; } },
  clientStorage: { getAsync: async () => undefined, setAsync: async () => {} },
  getLocalTextStylesAsync: async () => [
    { name: 'Body/Large', description: 'Body copy', fontSize: 16, fontName: { family: 'Ambit', style: 'Semi Bold Italic' }, lineHeight: { unit: 'PIXELS', value: 24 }, letterSpacing: { unit: 'PERCENT', value: -2 }, textDecoration: 'UNDERLINE' },
  ],
  getLocalEffectStylesAsync: async () => [
    { name: 'elevation/1', description: 'Cards', effects: [{ type: 'DROP_SHADOW', visible: true, color: { r: 0, g: 0, b: 0, a: 0.25 }, offset: { x: 0, y: 2 }, radius: 4, spread: 0 }] },
  ],
  getLocalPaintStylesAsync: async () => [
    { name: 'Gradient Dark', description: '', paints: [{ type: 'GRADIENT_LINEAR', visible: true, gradientTransform: [[1, 0, 0], [0, 1, 0]], gradientStops: [{ color: color(0.106, 0.067, 0.361), position: 0 }, { color: color(0.208, 0.404, 0.965), position: 1 }] }] },
    { name: 'Solid', description: '', paints: [{ type: 'SOLID', visible: true, color: color(1, 1, 1) }] },
  ],
  variables: {
    getLocalVariableCollectionsAsync: async () => [collections['VC:core'], collections['VC:ui']],
    getVariableByIdAsync: async (id) => variables[id] || null,
    getVariableCollectionByIdAsync: async (id) => collections[id] || null,
  },
};
eval(fs.readFileSync(__dirname + '/../lib/exporter/code.js', 'utf8'));
setTimeout(() => {
  if (message.error) { console.error(message.error); process.exit(1); }
  fs.writeFileSync(process.argv[2], message.json + '\n');
  console.log(`count=${message.count} collections=${message.collections}`);
}, 50);
