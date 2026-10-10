/// `GET /v1/files/:key?depth=2`: a cover page and an app page.
const Map<String, Object?> screensTree = {
  'name': 'App screens',
  'version': '7',
  'lastModified': '2026-10-01T00:00:00Z',
  'document': {
    'children': [
      {
        'type': 'CANVAS',
        'name': 'Cover',
        'children': [
          {'id': '9:1', 'type': 'FRAME', 'name': 'Cover'},
        ],
      },
      {
        'type': 'CANVAS',
        'name': 'App',
        'children': [
          {'id': '1:1', 'type': 'FRAME', 'name': 'Home'},
          {'id': '1:2', 'type': 'FRAME', 'name': 'Home dark'},
          {'id': '1:3', 'type': 'TEXT', 'name': 'Note'},
        ],
      },
    ],
  },
};
