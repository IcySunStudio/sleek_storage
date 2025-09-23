import 'dart:async';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'runner.dart';

class HiveRunner extends BenchmarkRunner {
  const HiveRunner();

  @override
  String get name => 'Hive CE';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    var homeDir = await getApplicationSupportDirectory();
    homeDir = Directory(path.join(homeDir.path, 'hive'));
    if (await homeDir.exists()) await homeDir.delete(recursive: true);
    homeDir = await homeDir.create();
    Hive.init(homeDir.path);
    const boxName = 'box';
    var box = await Hive.openBox<String>(boxName);

    // Write
    printNoBreak('[$name] Writing $operations items');
    final keys = List.generate(operations, (i) => 'key_$i');
    final writeDurationInMs = await runTimed(() async {
      await box.putAll({
        for (final key in keys) key: data,
      });
    });
    print(' - $writeDurationInMs ms');

    // Single write
    printNoBreak('[$name] Writing single item');
    final singleWriteDurationInMs = await runTimed(() async {
      await box.put('single_key', data);
    });
    print(' - $singleWriteDurationInMs ms');

    // Get file size
    int sizeInBytes = 0;
    for (final file in homeDir.listSync()) {
      if (file is File) {
        sizeInBytes += await file.length();
      }
    }

    // Reload storage
    printNoBreak('[$name] Reloading storage');
    await Hive.close();
    final reloadDurationInMs = await runTimed(() async {
      box = await Hive.openBox<String>(boxName);
    });
    print(' - $reloadDurationInMs ms');

    // Read
    printNoBreak('[$name] Reading $operations items');
    final readDurationInMs = await runTimed(() async {
      for (final key in keys) {
        box.get(key);
      }
    });
    print(' - $readDurationInMs ms');

    // Stream
    printNoBreak('[$name] Testing stream');
    final streamMeanDurationInMs = await runTimed(() async {
      final stream = box.watch(key: keys.first);
      final completer = Completer<void>();
      final subscription = stream.listen((event) {
        completer.complete();
      });
      unawaited(box.put(keys.first, data));
      await completer.future;
      unawaited(subscription.cancel());
    });
    print(' - $streamMeanDurationInMs ms');

    // Close storage
    print('[$name] Done, closing storage');
    await Hive.close();

    // Return results
    return BenchResult(
      writeDurationInMs: writeDurationInMs,
      singleWriteDurationInMs: singleWriteDurationInMs,
      reloadDurationInMs: reloadDurationInMs,
      readDurationInMs: readDurationInMs,
      streamMeanDurationInMs: streamMeanDurationInMs,
      fileSizeInBytes: sizeInBytes,
    );
  }
}
