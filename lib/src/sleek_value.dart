part of 'sleek_storage.dart';

T _identity<T>(dynamic object) => object as T;

sealed class _SleekValueBase<T> {
  _SleekValueBase(this.key, this._storage, ToJson<T>? toJson):
      _toJson = toJson ?? _identity;

  String get _rootKey;

  final String key;

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  void clear();

  /// Release all associated resources.
  void close();

  dynamic _encode();

  void _save() => _storage._save(_rootKey, key, _encode());
}

/// A single value stored in the [SleekStorage].
class SleekValue<T> extends _SleekValueBase<T> {
  SleekValue._internal(super.key, super._storage, dynamic data, FromJson<T>? fromJson, super.toJson):
      _value = data != null ? (fromJson ?? _identity)(data) : null;

  @override
  String get _rootKey => SleekStorage._valuesKey;

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
  void set(T? value) {
    _value = value;
    _stream?.add(value);
    _save();
  }

  @override
  void clear() => set(null);

  @override
  void close() => _stream?.close();

  @override
  dynamic _encode() => _value != null ? _toJson(_value as T) : null;
}

/// A collection of key-value pairs stored in the [SleekStorage].
class SleekBox<T> extends _SleekValueBase<T> {
  SleekBox._internal(super.key, super._storage, JsonObject? data, FromJson<T>? fromJson, super.toJson):
      _data = {
        for (final MapEntry(:key, :value) in (data ?? const {}).entries)
          key: (fromJson ?? _identity)(value),
      };

  @override
  String get _rootKey => SleekStorage._boxesKey;

  final Map<String, T> _data;

  DataStream<List<T>>? _stream;
  final Map<String, DataStream<T?>> _streams = {};


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
  void put(String key, T value) {
    _data[key] = value;
    _streams[key]?.add(value);
    _updateStream();
    _save();
  }

  /// Delete the value at the given [key] in the box.
  void delete(String key) {
    _data.remove(key);
    _closeStream(key);
    _updateStream();
    _save();
  }

  /// Clear all values in the box.
  @override
  void clear() {
    _data.clear();
    _closeAllStreams();
    _updateStream();
    _save();
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

  // TODO we could avoid re-encoding values that didn't change since last encoding using basic memory cache system
  @override
  JsonObject _encode() => {
    for (final MapEntry(:key, :value) in _data.entries)
      key: _toJson(value),
  };
}
