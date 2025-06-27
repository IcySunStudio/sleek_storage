import 'dart:io';

import 'package:csv/csv.dart';
import 'package:sleek_storage_benchmark/bench_result.dart';
import 'package:sleek_storage_benchmark/runners/shared_preferences.dart';

const benchmarks = [
  100,
  1000,
  /*10000,
  100000,
  1000000,*/    // TODO
];

const competitors = [
  SharedPreferencesRunner(),
];

void main() async {
  for (final operations in benchmarks) {
    print('Running benchmarks for $operations operations...');
    final results = <String, BenchResult>{};

    // Run all benchmarks
    for (final competitor in competitors) {
      print('Running ${competitor.name}...');
      final result = await competitor.run('test_data', operations);   // TODO use models
      results[competitor.name] = result;
      print('${competitor.name} completed: ${result.totalDuration.inMilliseconds} ms, Size: ${result.fileSizeInMB} MB');
    }

    // Save results to CSV
    final csv = const ListToCsvConverter().convert([
      ['Competitor', 'Write (ms)', 'Reload (ms)', 'Read (ms)', 'File Size (MB)'],
      for (final entry in results.entries)
        [entry.key, entry.value.writeDuration.inMilliseconds, entry.value.reloadDuration.inMilliseconds, entry.value.readDuration.inMilliseconds, entry.value.fileSizeInMB],
    ]);
    File('benchmark_#$operations.csv').writeAsStringSync(csv);
  }
}

/*
// Format a duration to "00.00 s"
String formatTime(Duration duration) {
  final seconds = duration.inMilliseconds / 1000;
  return '${seconds.toStringAsFixed(2)} s';
}

String formatSize(double size) {
  return '${size.toStringAsFixed(2)} MB';
}
*/