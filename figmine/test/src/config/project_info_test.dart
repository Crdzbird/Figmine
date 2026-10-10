import 'dart:io';

import 'package:figmine/src/config/project_info.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProjectInfo> _read(String? pubspec, {String? materialImport}) async {
  final root = await Directory.systemTemp.createTemp('figmine_project');
  addTearDown(() async => await root.delete(recursive: true));
  if (pubspec != null) {
    await File('${root.path}/pubspec.yaml').writeAsString(pubspec);
  }
  return await ProjectInfo.read(root.path, materialImport: materialImport);
}

void main() {
  group(ProjectInfo, () {
    test('defaults without a pubspec', () async {
      final info = await _read(null);
      expect(info.materialImport, 'package:flutter/material.dart');
      expect(info.modernConstructors, isFalse);
    });

    test('detects material_ui and Dart 3.13', () async {
      final info = await _read('''
name: my_app
environment: {sdk: ^3.13.0}
dependencies: {material_ui: ^1.6.0}
''');
      expect(info.packageName, 'my_app');
      expect(info.materialImport, 'package:material_ui/material_ui.dart');
      expect(info.modernConstructors, isTrue);
    });

    test('keeps classic syntax on older SDKs', () async {
      final info = await _read("environment: {sdk: '>=3.5.0 <4.0.0'}");
      expect(info.modernConstructors, isFalse);
    });

    test('a configured import wins', () async {
      final info = await _read(
        'dependencies: {material_ui: any}',
        materialImport: 'package:x/x.dart',
      );
      expect(info.materialImport, 'package:x/x.dart');
    });
  });
}
