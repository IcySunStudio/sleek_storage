import 'dart:async';

import 'package:sleek_storage/sleek_storage.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import '_runner.dart';

class SleekStorageRunner extends BenchmarkRunner {
  const SleekStorageRunner();

  @override
  String get name => 'Sleek Storage';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    final homeDir = await getClearDirectory('sleek_storage');
    var storage = await SleekStorage.getInstance(homeDir.path);
    const boxName = 'box';
    var box = storage.box<String>(boxName);

    // Write
    print('[$name] Writing $operations items');
    final keys = List.generate(operations, (i) => 'key_$i');
    final writeDurationInMs = await runTimed(() {
      return box.putAll({
        for (final key in keys) key: data,
      });
    });
    print('[$name] $operations items written in $writeDurationInMs ms');

    // Single write
    print('[$name] Writing single item');
    final singleWriteDurationInMs = await runTimed(() {
      return box.put('single_key', data);
    });
    print('[$name] single item written in $singleWriteDurationInMs ms');

    // Get file size
    final file = SleekStorage.getStorageFile(homeDir.path);
    final fileSize = await file.length();

    // Reload storage
    print('[$name] Reloading storage');
    await storage.close();
    final reloadDurationInMs = await runTimed(() async {
      storage = await SleekStorage.getInstance(homeDir.path);
      box = storage.box<String>(boxName);
    });
    print('[$name] Storage reloaded in $reloadDurationInMs ms');

    // Read
    print('[$name] Reading $operations items');
    final readDurationInMs = await runTimed(() async {
      for (final key in keys) {
        box.get(key);
      }
    });
    print('[$name] $operations items read in $readDurationInMs ms');

    // Stream
    print('[$name] Testing stream');
    final streamDurationsInMs = await runTimedAverage(streamRuns, () {
      final stream = box.watch(keys.first);
      final completer = Completer<Future<void>>();
      late final Future<void> closingFuture;
      late final StreamSubscription subscription;
      subscription = stream.listen((_) {
        completer.complete(closingFuture);
        subscription.cancel();
      });
      closingFuture = box.put(keys.first, data);
      return completer.future;
    });
    print('[$name] Stream tested in [Min: ${streamDurationsInMs.min} ms, Max: ${streamDurationsInMs.max} ms, Average: ${streamDurationsInMs.average} ms]');

    // Close storage
    print('[$name] Done, closing storage');
    await storage.close();

    // Return results
    return BenchResult(
      writeDurationInMs: writeDurationInMs,
      singleWriteDurationInMs: singleWriteDurationInMs,
      reloadDurationInMs: reloadDurationInMs,
      readDurationInMs: readDurationInMs,
      streamDurationStatsInMs: streamDurationsInMs,
      fileSizeInBytes: fileSize,
    );
  }
}
