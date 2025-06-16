import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'value_stream.dart';

part 'sleek_value.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonList = Iterable<dynamic>;

typedef FromJson<T> = T Function(dynamic json);
typedef ToJson<T> = dynamic Function(T object);

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
  final DataStream<DateTime> lastSavedAt;

  /// Loads and parses the storage from disk, inside the directory at [directoryPath].
  /// Returns a [SleekStorage] instance.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SleekStorage> getInstance(String directoryPath) async {
    // Get file instance
    final file = File(path.join(directoryPath, 'sleek.json'));

    // Load the file
    final data = await _readFromFileSafe(file) ?? {
      _valuesKey: JsonObject(),
      _boxesKey: JsonObject(),
    };

    // Get last saved date
    final lastSavedAt = DataStream<DateTime>(await file.lastModified());

    // Create and return the SleekStorage instance
    return SleekStorage._internal(file, data, lastSavedAt);
  }

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
  void _save(String rootKey, String key, dynamic jsonValue) async {
    // Save changed value
    _rawData[rootKey][key] = jsonValue;

    // Ask flush at the next event loop
    if (!_flushScheduled) {
      Future.delayed(Duration.zero, flush);
      _flushScheduled = true;
    }
  }

  /// Whether a flush is scheduled at next event loop.
  bool _flushScheduled = false;

  /// Write the current storage data to disk.
  /// This is automatically called when any data is modified, executed at the next current event loop.
  /// Call this method to ensure all changes are saved immediately.
  /// Returns a [Future] that completes when the data is written.
  Future<void> flush() async {
    _flushScheduled = false;
    await _saveToFile(_rawData, _file);
    lastSavedAt.add(await _file.lastModified());
  }

  /// Close the storage, releasing any resources.
  void close() {
    lastSavedAt.close();
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

  static Future<void> _saveToFile(JsonObject data, File file) async {
    final dataString = json.encode(data);   // TODO encode at field-level at each set, to ensure data integrity ?

    // Write to a temporary file first, then rename it to avoid data corruption
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(dataString, flush: true);
    await tempFile.rename(file.path);
  }
}