class BenchResult {
  const BenchResult({
    required this.writeDuration,
    required this.singleWriteDuration,
    required this.reloadDuration,
    required this.readDuration,
    this.streamDuration,
    required this.fileSizeInBytes,
  });

  final Duration writeDuration;
  final Duration singleWriteDuration;
  final Duration reloadDuration;
  final Duration readDuration;
  final Duration? streamDuration;
  final int fileSizeInBytes;

  Duration get totalDuration => writeDuration + singleWriteDuration + reloadDuration + readDuration;
  double get fileSizeInMB => fileSizeInBytes / (1024 * 1024);
  String get fileSizeDisplay => '${fileSizeInMB.toStringAsFixed(1)} MB';
}