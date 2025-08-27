part of 'sleek_storage.dart';

T _defaultFromJson<T>(String key, dynamic json) => json as T;
dynamic _defaultToJson<T>(T object) => object;

sealed class _SleekValueBase<T> {
  _SleekValueBase(this.key, this._storage, ToJson<T>? toJson):
      _toJson = toJson ?? _defaultToJson;

  String get _rootKey;

  final String key;

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  Future<void> clear();

  /// Release all associated resources.
  void close();

  dynamic _serialize();

  Future<void> _save() => _storage._save(_rootKey, key, _serialize());
}

/// A single value stored in the [SleekStorage].
class SleekValue<T> extends _SleekValueBase<T> {
  SleekValue._internal(super.key, super._storage, T? defaultValue, this._serializedValue, FromJson<T>? fromJson, super.toJson):
      _value = (_serializedValue != null ? (fromJson ?? _defaultFromJson)(key, _serializedValue) : null) ?? defaultValue;

  @override
  String get _rootKey => SleekStorage._valuesKey;

  /// Encoded value
  dynamic _serializedValue;

  /// Decoded value
  T? _value;

  DataStream<T?>? _stream;

  /// Get the current value.
  T? get value => _value;

  /// Same as [set]
  set value(T? newValue) => set(newValue);

  /// Returns a [DataStream] that emits the value when it changes.
  DataStream<T?> watch() => _stream ??= DataStream(value);

  /// Set new [value].
  /// Set it to null to clear the value.
  /// [value] is serialized immediately, throwing if it fails.
  /// Future completes when the value is set and saved to disk.
  Future<void> set(T? value) {
    _serializedValue = value != null ? _toJson(value) : null;
    _value = value;
    _stream?.add(value);
    return _save();
  }

  /// Clear the value.
  /// Future completes when the box is cleared and saved to disk.
  @override
  Future<void> clear() => set(null);

  @override
  void close() => _stream?.close();

  @override
  dynamic _serialize() => _serializedValue;
}

/// A collection of key-value pairs stored in the [SleekStorage].
///
/// You can iterate on the box directly to get all values (lazy iterator).
/// Modifying the map while iterating the values may break the iteration:
/// - Modifying existing items should be fine.
/// - Adding or removing items may throw a ConcurrentModificationError.
/// If you need the latter, you should iterate on [keys] instead, and get each nullable-value by key.
class SleekBox<T> extends _SleekValueBase<T> with Iterable<T> {
  SleekBox._internal(super.key, super._storage, JsonObject? data, FromJson<T>? fromJson, super.toJson):
      _serializedData = data ?? {},
      _data = {
        for (final MapEntry(:key, :value) in (data ?? const {}).entries)
          key: (fromJson ?? _defaultFromJson)(key, value),
      };

  @override
  String get _rootKey => SleekStorage._boxesKey;

  /// Data stored in the box, encoded
  final JsonObject _serializedData;

  /// Data stored in the box, decoded
  final Map<String, T> _data;

  /// Stream that emits all values in the box when any changes.
  /// Lazily created when [watchAll] is called.
  DataStream<List<T>>? _stream;

  /// Map of created streams
  /// Lazily created when [watch] is called.
  final Map<String, DataStream<T?>> _streams = {};

  /// Get the number of items in the box.
  @override
  int get length => _data.length;

  /// List all keys in the box.
  List<String> get keys => _data.keys.toList();

  /// Whether this box contains the given [key].
  bool containsKey(String? key) => _data.containsKey(key);

  /// Returns the value associated with the given [key].
  /// Or if the key does not exist:
  /// - [defaultValue] if specified,
  /// - Otherwise `null` is returned
  T? get(String key, {T? defaultValue}) => _data[key] ?? defaultValue;

  /// Same as [get]
  T? operator [](String key) => get(key);

  /// Returns all values in the box.
  /// Return a new `List` with all values.
  /// If you need to iterate on box on a async loop, you better iterate on the box directly, to ensure you get latest value (lazy iteration).
  List<T> getAll() => _data.values.toList();

  @override
  Iterator<T> get iterator => _data.values.iterator;

  /// Returns a [DataStream] that emits the value associated with the given [key] when it changes.
  /// If the key does not exist, or when value is deleted, it will emit `null`.
  DataStream<T?> watch(String key) => _streams.putIfAbsent(key,() => DataStream(get(key)));

  /// Returns a [DataStream] that emits all values in the box when any changes.
  DataStream<List<T>> watchAll() => _stream ??= DataStream<List<T>>(getAll());

  /// Saves the [value] at the [key] in the box.
  /// If the [key] already exists, it will be overwritten.
  /// [value] is serialized immediately, throwing if it fails.
  /// Future completes when the value is set and data saved to disk.
  Future<void> put(String key, T value) {
    _serializedData[key] = _toJson(value);
    _data[key] = value;
    _streams[key]?.add(value);
    _updateStream();
    return _save();
  }

  /// Same as [put]
  void operator []=(String key, T value) => put(key, value);

  /// Saves all the key-value pairs in the [entries] map.
  /// If the [key] already exists, it will be overwritten.
  /// [value] is serialized immediately, throwing if it fails.
  /// Future completes when values are set and data saved to disk.
  /// You'll have similar performance as multiple calls to [put] when NOT awaited.
  Future<void> putAll(Map<String, T> entries) {
    for (final MapEntry(:key, :value) in entries.entries) {
      _serializedData[key] = _toJson(value);
      _data[key] = value;
      _streams[key]?.add(value);
    }
    _updateStream();
    return _save();
  }

  /// Delete the value at the given [key] in the box.
  /// Future completes when the box is deleted from disk.
  Future<void> delete(String key) {
    _serializedData.remove(key);
    _data.remove(key);
    _streams[key]?.add(null);
    _updateStream();
    return _save();
  }

  /// Clear all values in the box.
  /// Future completes when the box is cleared and saved to disk.
  @override
  Future<void> clear() {
    _serializedData.clear();
    _data.clear();
    _streams.forEach((k, v) => v.add(null));
    _updateStream();
    return _save();
  }

  @override
  void close() {
    _closeAllStreams();
    _stream?.close();
  }

  void _updateStream() => _stream?.add(getAll());

  void _closeAllStreams() {
    for (final stream in _streams.values) {
      stream.close();
    }
    _streams.clear();
  }

  @override
  JsonObject _serialize() => _serializedData;
}
