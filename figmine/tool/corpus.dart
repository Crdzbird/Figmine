import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Regenerates each project offline, scores it against its reference with
/// and without tokens, and compares the scores with the committed baseline.
///
/// Usage: `dart run tool/corpus.dart [--update] <project folder>...`
///
/// Each project needs `figmine.yaml`, its lock file, the `.figmine` cache
/// and one `*reference.yaml`, but no dependency on figmine: it runs this
/// package's own command. Exits with code 1 when a score drops.
Future<void> main(List<String> args) async {
  final update = args.contains('--update');
  final projects = args.where((a) => !a.startsWith('--')).toList();
  final baselineFile = File(
    p.join(p.dirname(Platform.script.toFilePath()), 'corpus_baseline.json'),
  );
  final baseline = baselineFile.existsSync()
      ? (jsonDecode(await baselineFile.readAsString()) as Map<String, Object?>)
      : <String, Object?>{};
  final scores = <String, Map<String, double>>{};
  var dropped = false;
  for (final project in projects) {
    final name = p.basename(p.normalize(p.absolute(project)));
    final reference = Directory(project)
        .listSync()
        .map((e) => p.basename(e.path))
        .firstWhere((f) => f.endsWith('reference.yaml'));
    await _run(project, ['generate', '--offline']);
    final now = {
      'generated': _score(
        await _run(project, ['score', '--reference', reference]),
      ),
      'inferred': _score(
        await _run(project, ['score', '--reference', reference, '--inferred']),
      ),
    };
    scores[name] = now;
    final before = baseline[name] is Map
        ? baseline[name]! as Map
        : const <String, Object?>{};
    for (final MapEntry(key: kind, value: score) in now.entries) {
      final was = (before[kind] as num?)?.toDouble();
      final drop = was != null && score < was - 0.05;
      dropped = dropped || drop;
      final change = was == null
          ? 'new'
          : (drop ? 'DROPPED from $was' : 'was $was');
      stdout.writeln('$name $kind: $score% ($change)');
    }
  }
  if (update) {
    final merged = {...baseline, ...scores};
    await baselineFile.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(merged)}\n',
    );
    stdout.writeln('Updated ${baselineFile.path}.');
    return;
  }
  exitCode = dropped ? 1 : 0;
}

Future<String> _run(String project, List<String> args) async {
  final env = {...Platform.environment}..remove('FIGMA_TOKEN');
  final package = p.dirname(p.dirname(Platform.script.toFilePath()));
  final result = await Process.run(
    Platform.resolvedExecutable,
    [
      '--packages=${p.join(package, '.dart_tool', 'package_config.json')}',
      p.join(package, 'bin', 'figmine.dart'),
      ...args,
    ],
    workingDirectory: project,
    environment: env,
    includeParentEnvironment: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'figmine ${args.first} failed in $project:\n${result.stderr}',
    );
  }
  return '${result.stdout}';
}

double _score(String output) {
  final match = RegExp(r'Score: ([\d.]+)%').firstMatch(output);
  if (match == null) throw StateError('No score in:\n$output');
  return double.parse(match.group(1)!);
}
