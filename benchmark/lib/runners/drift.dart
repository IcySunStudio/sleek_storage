import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '_runner.dart';

part 'drift.g.dart';

class DriftRunner extends BenchmarkRunner {
  const DriftRunner();

  @override
  String get name => 'Drift';

  @override
  Future<BenchResult> run(String data, int operations) async {
    // Init and clear
    print('[$name] Init and clear');
    final homeDir = await getClearDirectory('drift');
    var database = AppDatabase(homeDir);

    // Write
    printNoBreak('[$name] Writing $operations items');
    final insertableData = StringItemsCompanion.insert(value: data);
    final writeDurationInMs = await runTimed(() {
      return database.batch((batch) {
        batch.insertAll(database.stringItems, [
          for (int i=0; i < operations; i++) insertableData,
        ]);
      });
    });
    print(' - $writeDurationInMs ms');

    // Single write
    printNoBreak('[$name] Writing single item');
    late final int id;
    final singleWriteDurationInMs = await runTimed(() async {
      id = await database.into(database.stringItems).insert(insertableData);
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
    await database.close();
    final reloadDurationInMs = await runTimed(() async {
      database = AppDatabase(homeDir);
    });
    print(' - $reloadDurationInMs ms');

    // Read
    printNoBreak('[$name] Reading $operations items');
    final readDurationInMs = await runTimed(() {
      return database.select(database.stringItems).get();
    });
    print(' - $readDurationInMs ms');

    // Stream
    printNoBreak('[$name] Testing stream');
    final streamDurationsInMs = await runTimedAverage(streamRuns, () {
      final stream = (database.select(database.stringItems)..where((t) => t.id.equals(id))).watchSingle();
      final completer = Completer<Future<void>>();
      late final Future<void> closingFuture;
      late final StreamSubscription subscription;
      subscription = stream.listen((_) {
        completer.complete(closingFuture);
        subscription.cancel();
      });
      closingFuture = database.update(database.stringItems).replace(StringItemsCompanion.insert(
        id: Value(id),
        value: data,
      ));
      return completer.future;
    });
    print(' - min: ${streamDurationsInMs.min} ms, max: ${streamDurationsInMs.max} ms, average: ${streamDurationsInMs.average} ms ($streamRuns runs)');

    // Close storage
    print('[$name] Done, closing storage');
    await database.close();

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

@DriftDatabase(tables: [StringItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(Directory directory) : super(driftDatabase(
    name: 'database',
    native: DriftNativeOptions(
      databaseDirectory: () async => directory,
    ),
  ));

  @override
  int get schemaVersion => 1;
}

class StringItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get value => text()();
}
