import 'package:figmine/src/lock/versions_section.dart';
import 'package:figmine/src/sources/version_history.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_figma.dart';

Map<String, Object?> _version(String id, [String label = '']) => {
  'id': id,
  'created_at': '2026-10-0${id}T10:00:00Z',
  'label': label,
  'description': label.isEmpty ? '' : 'New   buttons',
  'user': {'handle': 'luis'},
};

void main() {
  test('lists versions newer than the lock, newest first', () async {
    final versions = await VersionHistory(
      client: fakeFigma(
        json: {
          '/v1/files/KEY/versions': {
            'versions': [
              _version('3', 'Buttons v2'),
              _version('2'),
              _version('1'),
            ],
          },
        },
      ),
      fileKey: 'KEY',
    ).since('1');
    expect(versions.map((v) => v.id), ['3', '2']);
    final buffer = StringBuffer();
    VersionsSection.write(buffer, versions);
    expect(buffer.toString(), contains('### Figma changes (2 versions)'));
    expect(
      buffer.toString(),
      contains('- 2026-10-03 **Buttons v2** by luis: New buttons'),
    );
    expect(buffer.toString(), contains('- 2026-10-02 Autosave by luis'));
  });

  test('returns nothing without file_versions:read', () async {
    final versions = await VersionHistory(
      client: fakeFigma(errors: {'/v1/files/KEY/versions': 403}),
      fileKey: 'KEY',
    ).since('1');
    expect(versions, isEmpty);
  });
}
