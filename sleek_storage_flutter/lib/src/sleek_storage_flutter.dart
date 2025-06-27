import 'package:path_provider/path_provider.dart';
import 'package:sleek_storage/sleek_storage.dart';

class SleekStorageFlutter {
  /// Loads and parses the storage from disk.
  /// You can optionally specify a [directoryPath] to override the default Application Support Directory.
  /// You can optionally specify a [storageName] to use a custom file name.
  /// Returns a new [SleekStorage] instance.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in performance-sensitive blocks.
  static Future<SleekStorage> getInstance({String? directoryPath, String? storageName}) async {
    // Get directory path
    directoryPath ??= (await getApplicationSupportDirectory()).path;

    // Get SleekStorage instance
    return SleekStorage.getInstance(directoryPath, storageName: storageName);
  }
}
