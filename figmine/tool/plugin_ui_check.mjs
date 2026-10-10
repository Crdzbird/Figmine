import fs from 'node:fs';
import vm from 'node:vm';

const html = fs.readFileSync(new URL('../lib/exporter/ui.html', import.meta.url), 'utf8');
const script = html.slice(html.indexOf('<script>') + 8, html.indexOf('</script>'));
const element = () => ({ value: '', textContent: '', disabled: false, append() {} });
const elements = {};
const context = {
  document: { getElementById: (id) => (elements[id] ??= element()), createElement: element },
  atob, TextDecoder, URL, Blob, parent: { postMessage() {} }, console,
};
vm.createContext(context);
vm.runInContext(script, context);

const expect = (label, actual, expected) => {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    console.error(`${label}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
    process.exit(1);
  }
};

function github(state) {
  const calls = [];
  const reply = (status, body) => ({ ok: status < 300, status, json: async () => body });
  const request = async (url, init) => {
    const route = url.replace('https://api.github.com/repos/acme/app', '');
    calls.push(`${init.method} ${route}`);
    if (init.method === 'GET' && route === '/git/ref/heads/main') return reply(200, { object: { sha: 'base' } });
    if (init.method === 'GET' && route === '/git/commits/base') return reply(200, { tree: { sha: 'tree0' } });
    if (init.method === 'GET' && route.startsWith('/contents/')) {
      if (!state.file) return reply(404, {});
      return reply(200, { content: Buffer.from(state.file).toString('base64') });
    }
    if (init.method === 'GET' && route === '/git/ref/heads/figmine/tokens') {
      return state.branch ? reply(200, { object: { sha: 'old' } }) : reply(404, {});
    }
    if (route === '/git/trees') {
      const body = JSON.parse(init.body);
      expect('tree path', body.tree[0].path, 'design-tokens.json');
      return reply(201, { sha: 'tree1' });
    }
    if (route === '/git/commits') {
      expect('parents', JSON.parse(init.body).parents, ['base']);
      return reply(201, { sha: 'next' });
    }
    if (route === '/git/refs/heads/figmine/tokens') {
      expect('force', JSON.parse(init.body), { sha: 'next', force: true });
      return reply(200, {});
    }
    if (route === '/git/refs') {
      expect('new ref', JSON.parse(init.body), { ref: 'refs/heads/figmine/tokens', sha: 'next' });
      return reply(201, {});
    }
    return reply(500, {});
  };
  return { calls, request };
}

const tokens = (at, value) => JSON.stringify({ $extensions: { figmine: { exportedAt: at } }, color: { $value: value } });
const options = { repo: 'acme/app', base: 'main', path: 'design-tokens.json', token: 't', file: 'App' };

const fresh = github({});
const sent = await context.sendToGitHub({ ...options, json: tokens('1', '#fff') }, fresh.request);
expect('fresh changed', sent.changed, true);
expect('fresh creates branch', fresh.calls.at(-1), 'POST /git/refs');

const again = github({ file: tokens('1', '#fff'), branch: true });
const same = await context.sendToGitHub({ ...options, json: tokens('2', '#fff') }, again.request);
expect('unchanged tokens', same.changed, false);
expect('nothing written', again.calls.filter((c) => !c.startsWith('GET')), []);

const update = github({ file: tokens('1', '#fff'), branch: true });
await context.sendToGitHub({ ...options, json: tokens('2', '#000') }, update.request);
expect('updates branch', update.calls.at(-1), 'PATCH /git/refs/heads/figmine/tokens');

const denied = async () => ({ ok: false, status: 401, json: async () => ({}) });
const failure = await context.sendToGitHub({ ...options, json: '{}' }, denied).catch((e) => e.message);
expect('error message', failure, 'GitHub answered 401 to GET /git/ref/heads/main');
console.log('plugin ui ok');
