import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'runner.dart';

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
    printNoBreak('[$name] Writing $operations items');
    final keys = List.generate(operations, (i) => 'key_$i');
    final writeDuration = await runTimed(() async {
      for (final key in keys) {
        await storage.setString(key, data);
      }
    });
    print(' - ${writeDuration.inMilliseconds} ms');

    // Single write
    printNoBreak('[$name] Writing single item');
    final singleWriteDuration = await runTimed(() async {
      await storage.setString('single_key', data);
    });
    print(' - ${singleWriteDuration.inMilliseconds} ms');

    // Get file size
    final file = File(path.join((await getApplicationSupportDirectory()).path, 'shared_preferences.json'));
    final fileSize = await file.length();

    // Reload storage
    printNoBreak('[$name] Reloading storage');
    final reloadDuration = await runTimed(() async {
      storage = await SharedPreferences.getInstance();
      //TODO remove ?    await storage.reload();
    });
    print(' - ${reloadDuration.inMilliseconds} ms');

    // Read
    printNoBreak('[$name] Reading $operations items');
    final readDuration = await runTimed(() async {
      for (final key in keys) {
        storage.getString(key);
      }
    });
    print(' - ${readDuration.inMilliseconds} ms');

    // Close storage
    print('[$name] Done, closing storage');
    // Nothing to do.

    // Return results
    return BenchResult(
      writeDuration: writeDuration,
      singleWriteDuration: singleWriteDuration,
      reloadDuration: reloadDuration,
      readDuration: readDuration,
      fileSizeInBytes: fileSize,
    );
  }
}
