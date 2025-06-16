part of 'sleek_storage.dart';

typedef FromJson<T> = T Function(dynamic json);
typedef ToJson<T> = dynamic Function(T object);

T _identity<T>(dynamic object) => object as T;

class SleekBox<T> {
  SleekBox._internal(this._storage, JsonObject? data, this.name, FromJson<T>? fromJson, ToJson<T>? toJson):
      _toJson = toJson ?? _identity,
      _data = {
        for (final MapEntry(:key, :value) in (data ?? const {}).entries)
          key: (fromJson ?? _identity)(value),
      };

  final SleekStorage _storage;
  final ToJson<T> _toJson;

  final Map<String, T> _data;

  final String name;

  /// Returns the value associated with the given [key].
  /// Or if the key does not exist:
  /// - [defaultValue] if specified,
  /// - Otherwise `null` is returned
  T? get(String key, {T? defaultValue}) => _data[key] ?? defaultValue;

  /// Saves the [value] at the [key] in the box.
  Future<void> put(String key, T value) async {
    _data[key] = value;
    await _storage._save();
  }

  // TODO we could avoid re-encoding values that didn't change since last encoding
  JsonObject _encode() => {
    for (final MapEntry(:key, :value) in _data.entries)
      key: _toJson(value),
  };
}