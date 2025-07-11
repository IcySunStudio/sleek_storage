class BenchResult {
  const BenchResult({
    required this.writeDuration,
    required this.reloadDuration,
    required this.readDuration,
    required this.fileSizeInBytes,
  });

  final Duration writeDuration;
  final Duration reloadDuration;
  final Duration readDuration;
  final int fileSizeInBytes;

  Duration get totalDuration => writeDuration + reloadDuration + readDuration;
  double get fileSizeInMB => fileSizeInBytes / (1024 * 1024);
  String get fileSizeDisplay => '${fileSizeInMB.toStringAsFixed(1)} MB';
}