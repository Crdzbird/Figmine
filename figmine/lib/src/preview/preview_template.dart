import 'package:figmine/src/preview/gallery_data_template.dart';
import 'package:figmine/src/preview/gallery_template.dart';

/// The temporary widget test that renders the preview images.
abstract final class PreviewTemplate {
  /// Returns the test source. [imports] provide Material, the generated
  /// tokens and the theme; [light] and [dark] are ThemeData expressions.
  static String render({
    required List<String> imports,
    required String light,
    required String dark,
  }) {
    final sorted = [...imports]..sort();
    return '''
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
${sorted.map((u) => "import '$u';").join('\n')}

const String _out = String.fromEnvironment('FIGMINE_PREVIEW_OUT');

Future<void> _loadFonts(Iterable<String?> families) async {
  final loaded = <String>{};
  var manifest = '[]';
  try {
    manifest = await rootBundle.loadString('FontManifest.json');
  } on Object {
    manifest = '[]';
  }
  for (final entry in (jsonDecode(manifest) as List).cast<Map>()) {
    final family = '\${entry['family']}';
    final loader = FontLoader(family);
    for (final font in (entry['fonts'] as List).cast<Map>()) {
      loader.addFont(rootBundle.load('\${font['asset']}'));
    }
    await loader.load();
    loaded.add(family);
  }
  final dir = '\${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  Future<void> local(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final name in files) {
      final file = File('\$dir/\$name');
      if (!file.existsSync()) continue;
      loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    }
    await loader.load();
  }
  const roboto = ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf'];
  for (final family in {...families.whereType<String>(), 'Roboto'}) {
    if (!loaded.contains(family)) await local(family, roboto);
  }
  await local('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

${GalleryDataTemplate.source}
${GalleryTemplate.source}
void main() {
  final themes = [('light', $light), ('dark', $dark)];
  setUpAll(() async {
    await _loadFonts([
      for (final (_, theme) in themes)
        for (final style in [theme.textTheme.displaySmall,
          theme.textTheme.headlineSmall, theme.textTheme.titleMedium,
          theme.textTheme.bodyLarge, theme.textTheme.bodyMedium,
          theme.textTheme.labelLarge, theme.textTheme.labelMedium])
          style?.fontFamily,
    ]);
  });
  for (final (name, theme) in themes) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(900, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      debugDisableShadows = false;
      await tester.pumpWidget(RepaintBoundary(key: key, child: _gallery(theme)));
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('\$_out/\$name.png').writeAsBytes(bytes!.buffer.asUint8List());
      });
      debugDisableShadows = true;
    });
  }
}
''';
  }
}
