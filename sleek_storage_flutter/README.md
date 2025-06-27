Flutter version of [sleek_storage](https://pub.dev/packages/sleek_storage).

Allow Flutter projects to initialize a SleekStorage instance in the default Application Support directory directly.

```dart
// Initialize storage (optionally provide directoryPath and storageName)
final storage = await SleekStorageFlutter.getInstance();

// Use the storage instance directly
// See sleek_storage package documentation for usage examples
```
