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
    var homeDir = await getApplicationSupportDirectory();
    if (await homeDir.exists()) await homeDir.delete(recursive: true);
    homeDir = await homeDir.create();
    const boxName = 'box';
    var storage = await SleekStorage.getInstance(homeDir.path);
    var box = storage.box<String>(boxName);

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
    final file = SleekStorage.getStorageFile(homeDir.path);
    final fileSize = await file.length();

    // Reload storage
    printNoBreak('[$name] Reloading storage');
    await storage.close();
    final reloadDuration = await runTimed(() async {
      storage = await SleekStorage.getInstance(homeDir.path);
      box = storage.box<String>(boxName);
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

    // Close storage
    print('[$name] Done, closing storage');
    await storage.close();

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
