import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';

import 'package:csv/csv.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';
import 'package:sleek_storage_benchmark/models/test_model_advanced.dart';
import 'package:sleek_storage_benchmark/runners/hive.dart';
import 'package:sleek_storage_benchmark/runners/shared_preferences.dart';
import 'package:sleek_storage_benchmark/runners/sleek_storage.dart';

void main() async {
  // This ensures Flutter is initialized and dart:ui is available
  WidgetsFlutterBinding.ensureInitialized();

  // Run benchmarks
  await _runBenchmarks();

  // Exit the app when done
  exit(0);
}


const benchmarks = [
  1000,
  10000,
  100000,
  1000000,
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

    // Encode data
    final data = json.encode(TestModelAdvanced.random(2).toJson());

    // Run all benchmarks
    for (final competitor in competitors) {
      if (competitor.maxOperations != null && operations > competitor.maxOperations!) {
        print('Skipping ${competitor.name} for $operations operations (max: ${competitor.maxOperations})');
        continue;
      }
      print('Running ${competitor.name}...');
      final result = await competitor.run(data, operations);
      results[competitor.name] = result;
      print('${competitor.name} completed: ${result.totalDuration.inMilliseconds} ms, Size: ${result.fileSizeDisplay}');
    }

    // Save results to CSV
    final csv = const ListToCsvConverter().convert([
      ['Competitor', 'Write (ms)', 'Single Write (ms)', 'Reload (ms)', 'Read (ms)', 'Stream: Write-to-emit (ms)', 'File Size (MB)'],
      for (final entry in results.entries)
        [entry.key, entry.value.writeDuration.inMilliseconds, entry.value.singleWriteDuration.inMilliseconds, entry.value.reloadDuration.inMilliseconds, entry.value.readDuration.inMilliseconds, entry.value.streamDuration?.inMilliseconds ?? '-', entry.value.fileSizeDisplay],
    ]);
    final file = File('benchmark_#$operations.csv');
    await file.writeAsString(csv);
    print('=> Results saved to ${file.path}');
  }
}
