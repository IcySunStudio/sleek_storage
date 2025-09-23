import 'dart:io';

import 'package:sleek_storage_benchmark/bench_result.dart';

abstract class BenchmarkRunner {
  const BenchmarkRunner();

  String get name;

  int? get maxOperations => null;

  Future<BenchResult> run(String data, int operations);
}

/// Runs the given [action] and returns the elapsed time in milliseconds.
Future<int> runTimed(Future<void> Function() action) async {
  final stopwatch = Stopwatch()..start();
  await action();
  return stopwatch.elapsed.inMilliseconds;
}

void printNoBreak(String message) => stdout.write(message);
