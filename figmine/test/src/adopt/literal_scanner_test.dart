import 'package:figmine/src/adopt/literal_kind.dart';
import 'package:figmine/src/adopt/literal_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

const String _source = '''
Widget build() => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  decoration: BoxDecoration(
    color: const Color(0xFF2C2C2C),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(children: [
    Text('a', style: TextStyle(color: Color.fromARGB(255, 144, 11, 9))),
    const SizedBox(height: 24, child: Text('b')),
    Icon(Icons.star, color: Color.fromRGBO(255, 0, 0, 1)),
  ]),
);
// Color(0xFF000000) in a comment is not code.
''';

void main() {
  final found = LiteralScanner.scan(_source, 'lib/a.dart');

  test('finds colors in every notation and skips comments', () {
    final colors = found.where((l) => l.kind == LiteralKind.color).toList();
    expect(colors.map((c) => c.value), [0xFF2C2C2C, 0xFF900B09, 0xFFFF0000]);
    expect(colors.first.line, 4);
    expect(colors.first.owner, 'BoxDecoration');
    expect(colors[1].owner, 'TextStyle');
    expect(colors[1].property, 'color');
  });

  test('finds spacings in EdgeInsets and SizedBox sizes, and radii', () {
    final sizes = [
      for (final l in found)
        if (l.kind != LiteralKind.color) (l.kind, l.value),
    ];
    expect(sizes, [
      (LiteralKind.spacing, 12),
      (LiteralKind.spacing, 8),
      (LiteralKind.radius, 8),
      (LiteralKind.spacing, 24),
    ]);
  });
}
