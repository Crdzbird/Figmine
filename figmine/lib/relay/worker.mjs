function sameText(a, b) {
  if (typeof a !== 'string' || typeof b !== 'string' || a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

export default {
  async fetch(request, env) {
    if (request.method !== 'POST') return new Response('figmine relay');
    let event;
    try {
      event = await request.json();
    } catch {
      return new Response('Expected JSON', { status: 400 });
    }
    if (!sameText(event.passcode, env.FIGMA_WEBHOOK_PASSCODE)) {
      return new Response('Forbidden', { status: 403 });
    }
    if (event.event_type === 'PING') return new Response('pong');
    if (env.FIGMA_FILE_KEY && event.file_key !== env.FIGMA_FILE_KEY) {
      return new Response('Ignored');
    }
    const response = await fetch(
      `https://api.github.com/repos/${env.GITHUB_REPOSITORY}/dispatches`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${env.GITHUB_TOKEN}`,
          Accept: 'application/vnd.github+json',
          'User-Agent': 'figmine-relay',
        },
        body: JSON.stringify({
          event_type: 'figma-file-update',
          client_payload: {
            file_key: event.file_key,
            figma_event: event.event_type,
            triggered_by: event.triggered_by ? event.triggered_by.handle : null,
          },
        }),
      },
    );
    if (response.ok) return new Response('Dispatched', { status: 202 });
    return new Response(`GitHub answered ${response.status}`, { status: 502 });
  },
};
