/// Response of `GET /v1/files/:key/nodes` for the icons frame `1:2`.
const Map<String, Object?> iconNodesJson = {
  'nodes': {
    '1:2': {
      'document': {
        'id': '1:2',
        'type': 'FRAME',
        'name': 'Icons',
        'children': [
          {'id': '1:3', 'type': 'COMPONENT', 'name': 'icon/home'},
          {
            'id': '1:4',
            'type': 'COMPONENT_SET',
            'name': 'icon/arrow',
            'children': [
              {'id': '1:5', 'type': 'COMPONENT', 'name': 'Direction=Left'},
            ],
          },
          {'id': '1:6', 'type': 'COMPONENT', 'name': 'logo'},
        ],
      },
    },
  },
};

/// Response of `GET /v1/images/:key`.
const Map<String, Object?> imagesJson = {
  'err': null,
  'images': {
    '1:3': 'https://s3.example.com/home.svg',
    '1:5': 'https://s3.example.com/arrow.svg',
  },
};
