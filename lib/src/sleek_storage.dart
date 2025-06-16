import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

part 'sleek_box.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonList = Iterable<dynamic>;

typedef FromJson<T> = T Function(dynamic json);
typedef ToJson<T> = dynamic Function(T object);

class SleekStorage {
  SleekStorage._internal(this._file, this._rawData);

  static const _valuesKey = 'values';
  static const _boxesKey = 'boxes';

  final File _file;

  JsonObject _rawData;

  final Map<String, SleekValue> _values = {};
  final Map<String, SleekBox> _boxes = {};

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

    // Create and return the SleekStorage instance
    return SleekStorage._internal(file, data);
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

  /// Saves the current storage data to disk.
  Future<void> _save() async {
    // Encode all
    _rawData = {
      _valuesKey: _values.values.toJson(),
      _boxesKey: _boxes.values.toJson(),
    };

    // Save to file
    await _saveToFile(_rawData, _file);
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