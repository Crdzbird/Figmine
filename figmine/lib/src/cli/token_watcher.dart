import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Reruns a sync whenever watched files change.
abstract final class TokenWatcher {
  /// Calls [run] once, then again after each burst of changes to [paths],
  /// files or folders, until [until] completes, by default on Ctrl+C. A
  /// failing run is logged and watching goes on, as a file may be read
  /// halfway through a save.
  static Future<void> watch(
    List<String> paths,
    Future<void> Function() run, {
    required void Function(String message) log,
    Future<void>? until,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    final targets = {for (final path in paths) p.normalize(p.absolute(path))};
    final folders = targets.map(_folder).toSet();
    var running = _safe(run, log);
    await running;
    Timer? timer;
    final subscriptions = [
      for (final folder in folders)
        Directory(folder).watch().listen((event) {
          if (!_hits(targets, event.path)) return;
          timer?.cancel();
          timer = Timer(
            delay,
            () => running = running.then((_) => _safe(run, log)),
          );
        }),
    ];
    log('Watching ${paths.join(', ')}. Press Ctrl+C to stop.');
    await (until ?? ProcessSignal.sigint.watch().first);
    timer?.cancel();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await running;
  }

  static String _folder(String path) =>
      FileSystemEntity.isDirectorySync(path) ? path : p.dirname(path);

  static bool _hits(Set<String> targets, String path) {
    final changed = p.normalize(p.absolute(path));
    return targets.any((t) => t == changed || p.isWithin(t, changed));
  }

  static Future<void> _safe(
    Future<void> Function() run,
    void Function(String message) log,
  ) async {
    try {
      await run();
    } on Exception catch (error) {
      log('Sync failed: $error');
    }
  }
}
