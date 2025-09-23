import 'runners/_runner.dart';

class BenchResult {
  const BenchResult({
    required this.writeDurationInMs,
    required this.singleWriteDurationInMs,
    required this.reloadDurationInMs,
    required this.readDurationInMs,
    this.streamDurationStatsInMs,
    required this.fileSizeInBytes,
  });

  final int writeDurationInMs;
  final int singleWriteDurationInMs;
  final int reloadDurationInMs;
  final int readDurationInMs;
  final DurationStats? streamDurationStatsInMs;
  final int fileSizeInBytes;

  int get totalDurationInMs => writeDurationInMs + singleWriteDurationInMs + reloadDurationInMs + readDurationInMs + (streamDurationStatsInMs?.average ?? 0);
  double get fileSizeInMB => fileSizeInBytes / (1024 * 1024);
  String get fileSizeDisplay => '${fileSizeInMB.toStringAsFixed(1)} MB';
}