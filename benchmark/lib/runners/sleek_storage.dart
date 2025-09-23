import 'dart:async';

import 'package:sleek_storage/sleek_storage.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path_provider/path_provider.dart';

import '_runner.dart';

class SleekStorageRunner extends BenchmarkRunner {
  const SleekStorageRunner();

  @override
  String get name => 'Sleek Storage';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    var homeDir = await getApplicationSupportDirectory();
    if (await homeDir.exists()) await homeDir.delete(recursive: true);
    homeDir = await homeDir.create();
    const boxName = 'box';
    var storage = await SleekStorage.getInstance(homeDir.path);
    var box = storage.box<String>(boxName);

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
    final file = SleekStorage.getStorageFile(homeDir.path);
    final fileSize = await file.length();

    // Reload storage
    printNoBreak('[$name] Reloading storage');
    await storage.close();
    final reloadDurationInMs = await runTimed(() async {
      storage = await SleekStorage.getInstance(homeDir.path);
      box = storage.box<String>(boxName);
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
    const meanCount = 10;
    final streamDurationsInMs = await runTimedMean(meanCount, () {
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
    print(' - min: ${streamDurationsInMs.min} ms, max: ${streamDurationsInMs.max} ms, mean: ${streamDurationsInMs.mean} ms ($meanCount runs)');

    // Close storage
    print('[$name] Done, closing storage');
    await storage.close();

    // Return results
    return BenchResult(
      writeDurationInMs: writeDurationInMs,
      singleWriteDurationInMs: singleWriteDurationInMs,
      reloadDurationInMs: reloadDurationInMs,
      readDurationInMs: readDurationInMs,
      streamMeanDurationInMs: streamDurationsInMs.mean,
      fileSizeInBytes: fileSize,
    );
  }
}
