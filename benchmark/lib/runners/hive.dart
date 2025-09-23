import 'dart:async';
import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import '_runner.dart';

class HiveRunner extends BenchmarkRunner {
  const HiveRunner();

  @override
  String get name => 'Hive CE';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    final homeDir = await getClearDirectory('hive');
    Hive.init(homeDir.path);
    const boxName = 'box';
    var box = await Hive.openBox<String>(boxName);

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
    int sizeInBytes = 0;
    for (final file in homeDir.listSync()) {
      if (file is File) {
        sizeInBytes += await file.length();
      }
    }

    // Reload storage
    print('[$name] Reloading storage');
    await Hive.close();
    final reloadDurationInMs = await runTimed(() async {
      box = await Hive.openBox<String>(boxName);
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
      final stream = box.watch(key: keys.first);
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
    print('[$name] Stream test completed [Min: ${streamDurationsInMs.min} ms, Max: ${streamDurationsInMs.max} ms, Average: ${streamDurationsInMs.average} ms]');

    // Close storage
    print('[$name] Done, closing storage');
    await Hive.close();

    // Return results
    return BenchResult(
      writeDurationInMs: writeDurationInMs,
      singleWriteDurationInMs: singleWriteDurationInMs,
      reloadDurationInMs: reloadDurationInMs,
      readDurationInMs: readDurationInMs,
      streamDurationStatsInMs: streamDurationsInMs,
      fileSizeInBytes: sizeInBytes,
    );
  }
}
