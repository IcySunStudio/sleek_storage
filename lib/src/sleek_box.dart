part of 'sleek_storage.dart';

T _identity<T>(dynamic object) => object as T;

class SleekBox<T> {
  SleekBox._internal(this.name, this._storage, JsonObject? data, FromJson<T>? fromJson, ToJson<T>? toJson):
      _toJson = toJson ?? _identity,
      _data = {
        for (final MapEntry(:key, :value) in (data ?? const {}).entries)
          key: (fromJson ?? _identity)(value),
      };

  final String name;

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  final Map<String, T> _data;

  /// Returns the value associated with the given [key].
  /// Or if the key does not exist:
  /// - [defaultValue] if specified,
  /// - Otherwise `null` is returned
  T? get(String key, {T? defaultValue}) => _data[key] ?? defaultValue;

  /// Saves the [value] at the [key] in the box.
  Future<void> put(String key, T value) {
    _data[key] = value;
    return _storage._save();
  }

  // TODO we could avoid re-encoding values that didn't change since last encoding
  JsonObject _encode() => {
    for (final MapEntry(:key, :value) in _data.entries)
      key: _toJson(value),
  };
}

class SleekValue<T> {
  SleekValue._internal(this.key, this._storage, dynamic data, FromJson<T>? fromJson, ToJson<T>? toJson):
      _toJson = toJson ?? _identity,
      _value = data != null ? (fromJson ?? _identity)(data) : null;

  final String key;

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  T? _value;

  T? get value => _value;

  Future<void> set(T value) {
    _value = value;
    return _storage._save();
  }

  dynamic _encode() => _value != null ? _toJson(_value as T) : null;
}