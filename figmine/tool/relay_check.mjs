import worker from '../lib/relay/worker.mjs';

const env = {
  FIGMA_WEBHOOK_PASSCODE: 'secret',
  GITHUB_TOKEN: 'gh-token',
  GITHUB_REPOSITORY: 'acme/app',
  FIGMA_FILE_KEY: 'FILE',
};
const calls = [];
globalThis.fetch = async (url, init) => {
  calls.push({ url, init });
  return new Response(null, { status: 204 });
};
const post = (body) =>
  worker.fetch(new Request('https://relay.test', { method: 'POST', body: JSON.stringify(body) }), env);
const expect = (label, actual, expected) => {
  if (actual !== expected) {
    console.error(`${label}: expected ${expected}, got ${actual}`);
    process.exit(1);
  }
};

expect('wrong passcode', (await post({ passcode: 'nope', event_type: 'FILE_UPDATE' })).status, 403);
expect('ping', await (await post({ passcode: 'secret', event_type: 'PING' })).text(), 'pong');
expect('other file', await (await post({ passcode: 'secret', event_type: 'FILE_UPDATE', file_key: 'X' })).text(), 'Ignored');
expect('no dispatch yet', calls.length, 0);
const ok = await post({ passcode: 'secret', event_type: 'FILE_UPDATE', file_key: 'FILE', triggered_by: { handle: 'luis' } });
expect('dispatch status', ok.status, 202);
expect('dispatch url', calls[0].url, 'https://api.github.com/repos/acme/app/dispatches');
expect('auth header', calls[0].init.headers.Authorization, 'Bearer gh-token');
expect('event type', JSON.parse(calls[0].init.body).event_type, 'figma-file-update');
console.log('relay ok');
