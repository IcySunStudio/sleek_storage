## 2.0.0
* BREAKING: `Box.watch` now emits `null` when value is deleted or when box is cleared.
* BREAKING: `fromJson` now also provides the key.
* New: `SleekBox` is now a lazy `Iterable`.
* New: `SleekBox` now has index operators.
* New `Box.containsKey` method.
* New `SleekStorage.clear()` method.
* New optional `defaultValue` parameter on `SleekStorage.value()` method.
* Fix `Box.putAll` method.

## 1.0.0
* First stable release.

## 0.0.1
* Initial release.
