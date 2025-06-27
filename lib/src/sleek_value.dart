part of 'sleek_storage.dart';

T _identity<T>(dynamic object) => object as T;

sealed class _SleekValueBase<T> {
  _SleekValueBase(this.key, this._storage, ToJson<T>? toJson):
      _toJson = toJson ?? _identity;

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
  SleekValue._internal(super.key, super._storage, this._serializedValue, FromJson<T>? fromJson, super.toJson):
      _value = _serializedValue != null ? (fromJson ?? _identity)(_serializedValue) : null;

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
class SleekBox<T> extends _SleekValueBase<T> {
  SleekBox._internal(super.key, super._storage, JsonObject? data, FromJson<T>? fromJson, super.toJson):
      _serializedData = data ?? {},
      _data = {
        for (final MapEntry(:key, :value) in (data ?? const {}).entries)
          key: (fromJson ?? _identity)(value),
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
  int get length => _data.length;

  /// List all keys in the box.
  List<String> get keys => _data.keys.toList();

  /// Returns the value associated with the given [key].
  /// Or if the key does not exist:
  /// - [defaultValue] if specified,
  /// - Otherwise `null` is returned
  T? get(String key, {T? defaultValue}) => _data[key] ?? defaultValue;

  /// Returns all values in the box.
  List<T> getAll() => _data.values.toList();

  /// Returns a [DataStream] that emits the value associated with the given [key] when it changes.
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

  /// Delete the value at the given [key] in the box.
  /// Future completes when the box is deleted from disk.
  Future<void> delete(String key) {
    _serializedData.remove(key);
    _data.remove(key);
    _closeStream(key);
    _updateStream();
    return _save();
  }

  /// Clear all values in the box.
  /// Future completes when the box is cleared and saved to disk.
  @override
  Future<void> clear() {
    _serializedData.clear();
    _data.clear();
    _closeAllStreams();
    _updateStream();
    return _save();
  }

  @override
  void close() {
    _closeAllStreams();
    _stream?.close();
  }

  void _updateStream() => _stream?.add(getAll());

  void _closeStream(String key) => _streams.remove(key)?.close();

  void _closeAllStreams() {
    for (final stream in _streams.values) {
      stream.close();
    }
    _streams.clear();
  }

  @override
  JsonObject _serialize() => _serializedData;
}
