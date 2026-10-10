const TYPES = { COLOR: 'color', FLOAT: 'number', STRING: 'string' };
const WEIGHTS = [
  ['thin', 100], ['extra light', 200], ['extralight', 200], ['semi bold', 600],
  ['semibold', 600], ['extra bold', 800], ['extrabold', 800], ['light', 300],
  ['medium', 500], ['bold', 700], ['black', 900], ['heavy', 900],
];

function segments(name) {
  return name.split('/').map((s) => s.trim().replace(/\./g, '_')).filter(Boolean);
}

function hex(c) {
  const channels = [c.r, c.g, c.b].map((v) => Math.round(v * 255));
  return '#' + channels.map((v) => v.toString(16).padStart(2, '0')).join('').toUpperCase();
}

function encode(raw, type) {
  if (type !== 'color') return raw;
  const alpha = raw.a === undefined ? 1 : raw.a;
  return { colorSpace: 'srgb', components: [raw.r, raw.g, raw.b], alpha, hex: hex(raw) };
}

function weightOf(style) {
  const lower = style.toLowerCase();
  const match = WEIGHTS.find(([key]) => lower.includes(key));
  return match ? match[1] : 400;
}

function place(root, path, leaf) {
  let node = root;
  for (const key of path.slice(0, -1)) node = node[key] = node[key] || {};
  node[path[path.length - 1]] = leaf;
}

async function modeIn(collectionId, name) {
  const collection = await figma.variables.getVariableCollectionByIdAsync(collectionId);
  if (!collection) return null;
  const same = collection.modes.find((m) => m.name === name);
  return { collection, modeId: same ? same.modeId : collection.defaultModeId };
}

async function resolve(variable, modeName, depth) {
  const owner = await modeIn(variable.variableCollectionId, modeName);
  const raw = owner ? variable.valuesByMode[owner.modeId] : undefined;
  if (!raw || raw.type !== 'VARIABLE_ALIAS') return raw;
  const target = await figma.variables.getVariableByIdAsync(raw.id);
  return target && depth < 16 ? resolve(target, modeName, depth + 1) : undefined;
}

async function variableLeaf(variable, type, modes) {
  const values = {};
  const aliases = {};
  const resolved = {};
  for (const mode of modes) {
    const raw = variable.valuesByMode[mode.modeId];
    if (raw && raw.type === 'VARIABLE_ALIAS') {
      const target = await figma.variables.getVariableByIdAsync(raw.id);
      const final = target ? await resolve(target, mode.name, 0) : undefined;
      if (!target || final === undefined) continue;
      const owner = await modeIn(target.variableCollectionId, mode.name);
      values[mode.name] = '{' + segments(target.name).join('.') + '}';
      aliases[mode.name] = { collection: owner ? owner.collection.name : 'remote' };
      resolved[mode.name] = encode(final, type);
      continue;
    }
    if (raw !== undefined) values[mode.name] = encode(raw, type);
  }
  const first = values[modes[0].name];
  if (first === undefined) return null;
  const leaf = { $type: type, $value: first };
  if (variable.description) leaf.$description = variable.description;
  leaf.$extensions = { figmine: { values, aliases, resolved, variableId: variable.id } };
  return leaf;
}

function styleLeaf(style) {
  const size = style.fontSize;
  const value = {
    fontFamily: style.fontName.family,
    fontWeight: weightOf(style.fontName.style),
    fontSize: size,
  };
  const lh = style.lineHeight;
  if (lh.unit === 'PIXELS') value.lineHeight = lh.value / size;
  if (lh.unit === 'PERCENT') value.lineHeight = lh.value / 100;
  const ls = style.letterSpacing;
  if (ls.value) value.letterSpacing = ls.unit === 'PIXELS' ? ls.value : (ls.value * size) / 100;
  if (style.fontName.style.toLowerCase().includes('italic')) value.fontStyle = 'italic';
  if (style.textDecoration === 'UNDERLINE') value.textDecoration = 'underline';
  if (style.textDecoration === 'STRIKETHROUGH') value.textDecoration = 'line-through';
  const leaf = { $type: 'typography', $value: value };
  if (style.description) leaf.$description = style.description;
  return leaf;
}

function hexA(c) {
  const alpha = c.a === undefined ? 1 : c.a;
  if (alpha >= 1) return hex(c);
  return hex(c) + Math.round(alpha * 255).toString(16).padStart(2, '0').toUpperCase();
}

function described(leaf, style) {
  if (style.description) leaf.$description = style.description;
  return leaf;
}

function shadowLeaf(style) {
  const layers = style.effects
    .filter((e) => e.visible !== false && (e.type === 'DROP_SHADOW' || e.type === 'INNER_SHADOW'))
    .map((e) => ({
      color: hexA(e.color),
      offsetX: e.offset.x,
      offsetY: e.offset.y,
      blur: e.radius,
      spread: e.spread || 0,
      inset: e.type === 'INNER_SHADOW',
    }));
  if (!layers.length) return null;
  return described({ $type: 'shadow', $value: layers.length === 1 ? layers[0] : layers }, style);
}

function handles(m) {
  const [[a, b, c], [d, e, f]] = m;
  const det = a * e - b * d;
  const inv = [[e / det, -b / det, (b * f - c * e) / det], [-d / det, a / det, (c * d - a * f) / det]];
  const at = (x, y) => ({ x: inv[0][0] * x + inv[0][1] * y + inv[0][2], y: inv[1][0] * x + inv[1][1] * y + inv[1][2] });
  return [at(0, 0.5), at(1, 0.5), at(0, 1)];
}

function gradientLeaf(style) {
  const paint = style.paints.find((p) => p.visible !== false && p.type.startsWith('GRADIENT_'));
  if (!paint) return null;
  const value = {
    kind: paint.type.slice('GRADIENT_'.length).toLowerCase(),
    stops: paint.gradientStops.map((s) => ({ color: hexA(s.color), position: s.position })),
    handles: handles(paint.gradientTransform),
  };
  return described({ $type: 'gradient', $value: value }, style);
}

async function exportEffects(out) {
  const leaves = [
    ...(await figma.getLocalEffectStylesAsync()).map((s) => [s, shadowLeaf(s)]),
    ...(await figma.getLocalPaintStylesAsync()).map((s) => [s, gradientLeaf(s)]),
  ].filter(([, leaf]) => leaf);
  if (!leaves.length) return 0;
  const group = (out.Effects = { $extensions: { figmine: { modes: ['Value'] } } });
  for (const [style, leaf] of leaves) place(group, segments(style.name), leaf);
  return leaves.length;
}

async function exportTokens() {
  const out = {
    $extensions: {
      figmine: { format: 'collections', file: figma.root.name, exportedAt: new Date().toISOString() },
    },
  };
  let count = 0;
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  for (const collection of collections) {
    const isDefault = (m) => m.modeId === collection.defaultModeId;
    const modes = [...collection.modes.filter(isDefault), ...collection.modes.filter((m) => !isDefault(m))];
    const group = (out[collection.name] = { $extensions: { figmine: { modes: modes.map((m) => m.name) } } });
    for (const id of collection.variableIds) {
      const variable = await figma.variables.getVariableByIdAsync(id);
      const type = variable && TYPES[variable.resolvedType];
      const leaf = type ? await variableLeaf(variable, type, modes) : null;
      if (!leaf) continue;
      place(group, segments(variable.name), leaf);
      count++;
    }
  }
  const styles = await figma.getLocalTextStylesAsync();
  if (styles.length) {
    const group = (out['Text styles'] = { $extensions: { figmine: { modes: ['Value'] } } });
    for (const style of styles) {
      place(group, segments(style.name), styleLeaf(style));
      count++;
    }
  }
  count += await exportEffects(out);
  return { json: JSON.stringify(out, null, 2), count, collections: collections.length };
}

figma.showUI(__html__, { width: 340, height: 420 });
figma.ui.onmessage = async (message) => {
  if (message.type === 'save') await figma.clientStorage.setAsync('github', message.settings);
};
Promise.all([exportTokens(), figma.clientStorage.getAsync('github')])
  .then(([result, github]) => figma.ui.postMessage({ ...result, file: figma.root.name, github: github || null }))
  .catch((error) => figma.ui.postMessage({ error: String(error) }));
