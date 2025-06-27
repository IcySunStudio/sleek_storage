import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:csv/csv.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';
import 'package:sleek_storage_benchmark/runners/hive.dart';
import 'package:sleek_storage_benchmark/runners/shared_preferences.dart';
import 'package:sleek_storage_benchmark/runners/sleek_storage.dart';

void main() async {
  // This ensures Flutter is initialized and dart:ui is available
  WidgetsFlutterBinding.ensureInitialized();

  // Run benchmarks
  await _runBenchmarks();
}


const benchmarks = [
  100,
  1000,
  /*10000,
  100000,
  1000000,*/    // TODO
];

const competitors = [
  SleekStorageRunner(),
  SharedPreferencesRunner(),
  HiveRunner(),
];

Future<void> _runBenchmarks() async {
  for (final operations in benchmarks) {
    print('--- Running benchmarks for $operations operations ---');
    final results = <String, BenchResult>{};

    // Run all benchmarks
    for (final competitor in competitors) {
      print('Running ${competitor.name}...');
      final result = await competitor.run('test_data', operations);   // TODO use models
      results[competitor.name] = result;
      print('${competitor.name} completed: ${result.totalDuration.inMilliseconds} ms, Size: ${result.fileSizeDisplay}');
    }

    // Save results to CSV
    final csv = const ListToCsvConverter().convert([
      ['Competitor', 'Write (ms)', 'Reload (ms)', 'Read (ms)', 'File Size (MB)'],
      for (final entry in results.entries)
        [entry.key, entry.value.writeDuration.inMilliseconds, entry.value.reloadDuration.inMilliseconds, entry.value.readDuration.inMilliseconds, entry.value.fileSizeDisplay],
    ]);
    final file = File('benchmark_#$operations.csv');
    await file.writeAsString(csv);
    print('=> Results saved to ${file.path}');
  }
}
