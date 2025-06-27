import 'package:sleek_storage/sleek_storage.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path_provider/path_provider.dart';

import 'runner.dart';

class SleekStorageRunner extends BenchmarkRunner {
  const SleekStorageRunner();

  @override
  String get name => 'Sleek Storage';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    final homeDir = await getApplicationSupportDirectory();
    const boxName = 'box';
    var storage = await SleekStorage.getInstance(homeDir.path);
    var box = await storage.box<String>(boxName);

    // Write
    print('[$name] Writing $operations items');
    final keys = List.generate(operations, (i) => 'key_$i');
    final writeDuration = await runTimed(() async {
      await box.putAll({
        for (final key in keys) key: data,
      });
    });

    // Get file size
    final file = SleekStorage.getStorageFile(homeDir.path);
    final fileSize = await file.length();

    // Reload storage
    print('[$name] Reloading storage');
    await storage.close();
    final reloadDuration = await runTimed(() async {
      storage = await SleekStorage.getInstance(homeDir.path);
      box = await storage.box<String>(boxName);
    });

    // Read
    print('[$name] Reading $operations items');
    final readDuration = await runTimed(() async {
      for (final key in keys) {
        box.get(key);
      }
    });

    // Close storage
    print('[$name] Done, closing storage');
    await storage.close();

    // Return results
    return BenchResult(
      writeDuration: writeDuration,
      reloadDuration: reloadDuration,
      readDuration: readDuration,
      fileSizeInBytes: fileSize,
    );
  }
}
