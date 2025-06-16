part of 'sleek_storage.dart';

T _identity<T>(dynamic object) => object as T;

sealed class _SleekValueBase<T> {
  _SleekValueBase(this.key, this._storage, ToJson<T>? toJson):
      _toJson = toJson ?? _identity;

  final String key;

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  dynamic _encode();
}

/// A single value stored in the [SleekStorage].
class SleekValue<T> extends _SleekValueBase<T> {
  SleekValue._internal(super.key, super._storage, dynamic data, FromJson<T>? fromJson, super.toJson):
      _value = data != null ? (fromJson ?? _identity)(data) : null;

  T? _value;

  T? get value => _value;

  Future<void> set(T value) {
    _value = value;
    return _storage._save();
  }

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
  @override
  JsonObject _encode() => {
    for (final MapEntry(:key, :value) in _data.entries)
      key: _toJson(value),
  };
}

extension _SleekValueBaseIterable on Iterable<_SleekValueBase> {
  JsonObject toJson() => {
    for (final value in this)
      value.key: value._encode(),
  };
}
