class BenchResult {
  const BenchResult({
    required this.writeDurationInMs,
    required this.singleWriteDurationInMs,
    required this.reloadDurationInMs,
    required this.readDurationInMs,
    this.streamMeanDurationInMs,
    required this.fileSizeInBytes,
  });

  final int writeDurationInMs;
  final int singleWriteDurationInMs;
  final int reloadDurationInMs;
  final int readDurationInMs;
  final int? streamMeanDurationInMs;
  final int fileSizeInBytes;

  int get totalDurationInMs => writeDurationInMs + singleWriteDurationInMs + reloadDurationInMs + readDurationInMs + (streamMeanDurationInMs ?? 0);
  double get fileSizeInMB => fileSizeInBytes / (1024 * 1024);
  String get fileSizeDisplay => '${fileSizeInMB.toStringAsFixed(1)} MB';
}