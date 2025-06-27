import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:value_stream/value_stream.dart';

part 'sleek_value.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonList = Iterable<dynamic>;

typedef FromJson<T> = T Function(dynamic json);
typedef ToJson<T> = dynamic Function(T object);

/// Storage system that allows you to store values and boxes in a JSON file.
///
/// You can create boxes to store multiple values of the same type, or use single values directly.
/// You can listen to changes in values and boxes using the watch method.
///
/// At each modification, data is serialized to Dart-native objects immediately,
/// then on the next event loop, it's encoded in JSON String and written to disk, in a JSON file.
class SleekStorage {
  SleekStorage._internal(this._file, this._rawData, this.lastSavedAt);

  static const _valuesKey = 'values';
  static const _boxesKey = 'boxes';

  /// The file where the storage is saved.
  final File _file;

  /// Serialized data of the storage.
  final JsonObject _rawData;

  /// All opened values.
  final Map<String, SleekValue> _values = {};

  /// All opened boxes.
  final Map<String, SleekBox> _boxes = {};

  /// A stream that emits the last saved date of the storage, when it is saved to disk.
  /// You could listen to this stream to know when storage is saved to disk.
  /// Value is null if the storage has never been saved.
  final DataStream<DateTime?> lastSavedAt;

  /// Loads and parses the storage from disk, inside the directory at [directoryPath].
  /// You can optionally specify a [storageName] to use a custom file name.
  /// Returns a new [SleekStorage] instance.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in performance-sensitive blocks.
  static Future<SleekStorage> getInstance(String directoryPath, {String? storageName}) async {
    // Get file instance
    final file = getStorageFile(directoryPath, storageName);

    // Load the file
    final data = await _readFromFileSafe(file) ?? {
      _valuesKey: JsonObject(),
      _boxesKey: JsonObject(),
    };

    // Get last saved date
    final lastModifiedAt = await file.exists() ? await file.lastModified() : null;
    final lastSavedAt = DataStream<DateTime?>(lastModifiedAt);

    // Create and return the SleekStorage instance
    return SleekStorage._internal(file, data, lastSavedAt);
  }

  /// Get the storage file, given a [directoryPath] and an optional [storageName].
  static File getStorageFile(String directoryPath, [String? storageName]) => File(path.join(directoryPath, '${storageName ?? 'sleek'}.json'));

  /// Get or create a box named [boxName].
  /// All items of the box must be of the same type [T].
  /// If [fromJson] and [toJson] are omitted, [T] must be a primitive, JSON-compatible type.
  SleekBox<T> box<T>(String boxName, {FromJson<T>? fromJson, ToJson<T>? toJson}) {
    return _boxes.putIfAbsent(
      boxName,
      () => SleekBox<T>._internal(
        boxName,
        this,
        _rawData[_boxesKey][boxName],
        fromJson,
        toJson,
      ),
    ) as SleekBox<T>;
  }

  /// Get or create a [SleekValue] for the given [key].
  SleekValue<T> value<T>(String key, {FromJson<T>? fromJson, ToJson<T>? toJson}) {
    return _values.putIfAbsent(
      key,
      () => SleekValue<T>._internal(
        key,
        this,
        _rawData[_valuesKey][key],
        fromJson,
        toJson,
      ),
    ) as SleekValue<T>;
  }

  /// List all keys of the [SleekValue]s.
  List<String> getAllValuesKeys() => _rawData[_valuesKey].keys.toList();

  /// List all keys of the [SleekBox]es.
  List<String> getAllBoxesKeys() => _rawData[_boxesKey].keys.toList();

  /// Commit change to storage, and ask to save to disk.
  Future<void> _save(String rootKey, String key, dynamic jsonValue) {
    // Save changed value
    _rawData[rootKey][key] = jsonValue;

    // Ask flush
    return flush();
  }

  /// Future that is running a flush operation (while flush is pending & file is being written to disk).
  Future<void>? _runningFlushFuture;

  /// Write the current storage data to disk.
  /// This is automatically called when any data is modified, executed at the next current event loop.
  /// Returns a [Future] that completes when the data is written.
  /// If a flush is already pending, it will just wait for it to complete.
  /// If file is being written, it will wait for it to complete, then flush it again.
  ///
  /// You should never need to call this method directly.
  Future<void> flush() async {
    if (_runningFlushFuture == null) {
      // If no flush is in progress, start a new one
      try {
        _runningFlushFuture = _doFlush();
        await _runningFlushFuture;
      } finally {
        _runningFlushFuture = null;
      }
    } else {
      // If a flush is already in progress, wait for it to complete
      final shouldFlushAgain = _writeRunning;
      await _runningFlushFuture;

      // Then schedule another flush
      if (shouldFlushAgain) {
        await flush();
      }
    }
  }

  /// Whether file is currently being written.
  bool _writeRunning = false;

  /// Internal method that performs the actual flush operation.
  Future<void> _doFlush() async {
    // Wait next event loop, to ensure to encode latest data if multiple changes happened in the same event loop.
    await Future.delayed(Duration.zero);

    // Encode data to JSON string
    final dataString = json.encode(_rawData);   // TODO handle errors

    // Write to file
    try {
      _writeRunning = true;
      await _writeToFile(dataString, _file);
      lastSavedAt.add(await _file.lastModified(), skipIfClosed: true);
    } finally {
      _writeRunning = false;
    }
  }

  /// Close the storage, releasing any resources.
  /// Future completes when storage is fully written to disk and closed.
  Future<void> close() async {
    await _runningFlushFuture;
    lastSavedAt.close();
  }

  /// Delete the storage file from disk.
  static Future<void> deleteStorage(String directoryPath, {String? storageName}) async {
    final file = getStorageFile(directoryPath, storageName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<JsonObject?> _readFromFileSafe(File file) async {
    try {
      if (await file.exists()) {
        final dataString = await file.readAsString();
        if (dataString.isNotEmpty) {
          return json.decode(dataString);
        }
      }
    } catch(e) {
      // TODO handle error
    }
    return null;
  }

  static Future<void> _writeToFile(String data, File file) async {
    // Write to a temporary file first, then rename it to avoid data corruption
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(data, flush: true);
    await tempFile.rename(file.path);
  }
}