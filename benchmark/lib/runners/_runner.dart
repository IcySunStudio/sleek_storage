import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sleek_storage_benchmark/bench_result.dart';

const streamRuns = 10;

abstract class BenchmarkRunner {
  const BenchmarkRunner();

  String get name;

  int? get maxOperations => null;

  Future<BenchResult> run(String data, int operations);
}

/// Returns a cleared directory at the given [subdir], where data can be stored.
Future<Directory> getClearDirectory(String subdir) async {
  var homeDir = await getApplicationSupportDirectory();
  homeDir = Directory(path.join(homeDir.path, subdir));
  if (await homeDir.exists()) await homeDir.delete(recursive: true);
  return await homeDir.create();
}

/// Runs the given [action] and returns the elapsed time in milliseconds.
Future<int> runTimed(Future<void> Function() action) async {
  final stopwatch = Stopwatch()..start();
  await action();
  return stopwatch.elapsed.inMilliseconds;
}

/// Callback that returns a future to be measured, which itself return a future to be completed after the measured future is done
typedef BenchmarkCallback = Future<Future<void>> Function();

Future<DurationStats> runTimedAverage(int count, BenchmarkCallback action) async {
  var totalMilliseconds = 0;
  var minMilliseconds = 10000000;
  var maxMilliseconds = 0;
  for (var i = 0; i < count; i++) {
    // Run task
    late final Future<void> closingFuture;
    final duration = (await runTimed(() async {
      closingFuture = await action();
    }));

    // Collect stats
    totalMilliseconds += duration;
    if (duration < minMilliseconds) minMilliseconds = duration;
    if (duration > maxMilliseconds) maxMilliseconds = duration;

    // Wait for closing
    await closingFuture;
  }
  return DurationStats(
    average: totalMilliseconds ~/ count,
    min: minMilliseconds,
    max: maxMilliseconds,
  );
}

class DurationStats {
  const DurationStats({required this.average, required this.min, required this.max});

  final int average;
  final int min;
  final int max;
}
