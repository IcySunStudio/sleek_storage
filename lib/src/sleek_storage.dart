import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'sleek_box.dart';

typedef JsonObject = Map<String, dynamic>;
typedef JsonList = Iterable<dynamic>;

class SleekStorage {
  SleekStorage._internal(this._file, this._rawData);

  static const _rootKey = 'root';
  static const _boxesKey = 'boxes';

  final File _file;

  JsonObject _rawData;

  late final SleekBox<dynamic> _rootBox = SleekBox._internal(
    this,
    _rawData[_rootKey],
    _rootKey,
    (json) => json,   // TODO
    (object) => object, // TODO
  );
  final Map<String, SleekBox> _boxes = {};

  /// Loads and parses the storage from disk.
  /// Returns a [SleekStorage] instance.
  ///
  /// Because this is reading from disk, it shouldn't be awaited in
  /// performance-sensitive blocks.
  static Future<SleekStorage> getInstance() async {
    // Get file instance
    final file = await _getFile();

    // Load the file
    final data = await _readFromFileSafe(file) ?? {
      _rootKey: {},
      _boxesKey: {},
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
        this,
        _rawData[_boxesKey][boxName],
        boxName,
        fromJson,
        toJson,
      ),
    ) as SleekBox<T>;
  }

  /// Saves the current storage data to disk.
  Future<void> _save() async {
    // Encode all
    _rawData = {
      _rootKey: _rootBox._encode(),
      _boxesKey: {
        for (final entry in _boxes.entries)
          entry.key: entry.value._encode(),
      },
    };

    // Save to file
    await _saveToFile(_rawData, _file);
  }

  static Future<File> _getFile() async {
    final directory = await getApplicationSupportDirectory();
    return File(path.join(directory.path, 'sleek.json'));
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