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
    final writeDuration = await runTimed(() async {
      await box.putAll({
        for (final key in keys) key: data,
      });
    });
    print(' - ${writeDuration.inMilliseconds} ms');

    // Single write
    printNoBreak('[$name] Writing single item');
    final singleWriteDuration = await runTimed(() async {
      await box.put('single_key', data);
    });
    print(' - ${singleWriteDuration.inMilliseconds} ms');

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
    final reloadDuration = await runTimed(() async {
      box = await Hive.openBox<String>(boxName);
    });
    print(' - ${reloadDuration.inMilliseconds} ms');

    // Read
    printNoBreak('[$name] Reading $operations items');
    final readDuration = await runTimed(() async {
      for (final key in keys) {
        box.get(key);
      }
    });
    print(' - ${readDuration.inMilliseconds} ms');

    // Stream
    printNoBreak('[$name] Testing stream');
    final streamDuration = await runTimed(() async {
      final stream = box.watch(key: keys.first);
      final completer = Completer<void>();
      final subscription = stream.listen((event) {
        completer.complete();
      });
      unawaited(box.put(keys.first, data));
      await completer.future;
      unawaited(subscription.cancel());
    });
    print(' - ${streamDuration.inMilliseconds} ms');

    // Close storage
    print('[$name] Done, closing storage');
    await Hive.close();

    // Return results
    return BenchResult(
      writeDuration: writeDuration,
      singleWriteDuration: singleWriteDuration,
      reloadDuration: reloadDuration,
      readDuration: readDuration,
      streamDuration: streamDuration,
      fileSizeInBytes: sizeInBytes,
    );
  }
}
