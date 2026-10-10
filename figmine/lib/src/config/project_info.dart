import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Facts about the consuming project that shape the generated code.
final class ProjectInfo {
  /// Creates project facts.
  const factory({
    String materialImport,
    bool modernConstructors,
    String? packageName,
  }) = ProjectInfo._;

  const new _({
    this.materialImport = 'package:flutter/material.dart',
    this.modernConstructors = false,
    this.packageName,
  });

  /// Reads `pubspec.yaml` in [root]. A configured [materialImport] wins.
  ///
  /// Projects that depend on `material_ui` import that package. Projects on
  /// Dart 3.13 or newer get the `new` constructor syntax.
  static Future<ProjectInfo> read(String root, {String? materialImport}) async {
    final file = File(p.join(root, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return ProjectInfo(materialImport: materialImport ?? _flutterMaterial);
    }
    final yaml = loadYaml(await file.readAsString());
    final pubspec = yaml is Map ? yaml : const <Object?, Object?>{};
    final deps = pubspec['dependencies'];
    final usesMaterialUi = deps is Map && deps.containsKey('material_ui');
    final environment = pubspec['environment'];
    final sdk = environment is Map ? '${environment['sdk']}' : '';
    return ProjectInfo(
      materialImport:
          materialImport ??
          (usesMaterialUi ? 'package:material_ui/material_ui.dart' : null) ??
          _flutterMaterial,
      modernConstructors: _atLeast(sdk, 3, 13),
      packageName: pubspec['name'] is String ? '${pubspec['name']}' : null,
    );
  }

  static const String _flutterMaterial = 'package:flutter/material.dart';

  static bool _atLeast(String constraint, int major, int minor) {
    final match = RegExp(r'(\d+)\.(\d+)').firstMatch(constraint);
    if (match == null) return false;
    final foundMajor = int.parse(match.group(1)!);
    final foundMinor = int.parse(match.group(2)!);
    return foundMajor > major || (foundMajor == major && foundMinor >= minor);
  }

  /// Import that provides Material.
  final String materialImport;

  /// The package name, used for `package:` imports of generated files.
  final String? packageName;

  /// Whether constructors use the Dart 3.13 `new` and unnamed syntax.
  final bool modernConstructors;
}
