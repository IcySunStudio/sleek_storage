import 'package:path_provider/path_provider.dart';
import 'package:sleek_storage/sleek_storage.dart';

class SleekStorageFlutter {
  /// Loads and parses the storage from disk.
  /// You can optionally specify a [directoryPath] to override the default Application Support Directory.
  /// You can optionally specify a [storageName] to use a custom file name.
  /// Returns a new [SleekStorage] instance.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in performance-sensitive blocks.
  /// It may throw if store can't be read.
  static Future<SleekStorage> getInstance({String? directoryPath, String? storageName}) async {
    // Get directory path
    directoryPath ??= await _getDefaultDirectoryPath();

    // Get SleekStorage instance
    return await SleekStorage.getInstance(directoryPath, storageName: storageName);
  }

  /// Delete the storage file from disk.
  /// /!\ All data is still in memory: you should call this method before creating a new storage instance.
  static Future<void> deleteStorage({String? directoryPath, String? storageName}) async {
    // Get directory path
    directoryPath ??= await _getDefaultDirectoryPath();

    // Delete storage
    await SleekStorage.deleteStorage(directoryPath, storageName: storageName);
  }

  static Future<String> _getDefaultDirectoryPath() async => (await getApplicationSupportDirectory()).path;
}
