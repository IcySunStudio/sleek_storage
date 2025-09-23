import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '_runner.dart';

class SharedPreferencesRunner extends BenchmarkRunner {
  const SharedPreferencesRunner();

  @override
  String get name => 'Shared Preferences';

  @override
  int? get maxOperations => 1000;   // SharedPreferences is very slow

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    var storage = await SharedPreferences.getInstance();
    await storage.clear();

    // Write
    print('[$name] Writing $operations items');
    final keys = List.generate(operations, (i) => 'key_$i');
    final writeDurationInMs = await runTimed(() async {
      for (final key in keys) {
        await storage.setString(key, data);
      }
    });
    print('[$name] $operations items written in $writeDurationInMs ms');

    // Single write
    print('[$name] Writing single item');
    final singleWriteDurationInMs = await runTimed(() {
      return storage.setString('single_key', data);
    });
    print('[$name] single item written in $singleWriteDurationInMs ms');

    // Get file size
    final file = File(path.join((await getApplicationSupportDirectory()).path, 'shared_preferences.json'));
    final fileSize = await file.length();

    // Reload storage
    print('[$name] Reloading storage');
    final reloadDurationInMs = await runTimed(() async {
      storage = await SharedPreferences.getInstance();
      //TODO remove ?    await storage.reload();
    });
    print('[$name] Storage reloaded in $reloadDurationInMs ms');

    // Read
    print('[$name] Reading $operations items');
    final readDurationInMs = await runTimed(() async {
      for (final key in keys) {
        storage.getString(key);
      }
    });
    print('[$name] $operations items read in $readDurationInMs ms');

    // Close storage
    print('[$name] Done, closing storage');
    // Nothing to do.

    // Return results
    return BenchResult(
      writeDurationInMs: writeDurationInMs,
      singleWriteDurationInMs: singleWriteDurationInMs,
      reloadDurationInMs: reloadDurationInMs,
      readDurationInMs: readDurationInMs,
      fileSizeInBytes: fileSize,
    );
  }
}
