![sleek_storage_flutter](https://raw.githubusercontent.com/IcySunStudio/sleek_storage/refs/heads/main/banner.png)

[![Pub](https://img.shields.io/pub/v/sleek_storage_flutter.svg?label=sleek_storage_flutter)](https://pub.dartlang.org/packages/sleek_storage_flutter)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)

Flutter version of [sleek_storage](https://pub.dev/packages/sleek_storage).

Allow Flutter projects to initialize a SleekStorage instance in the default Application Support directory directly.

```dart
// Initialize storage (optionally provide directoryPath and storageName)
final storage = await SleekStorageFlutter.getInstance();

// Use the storage instance directly
// See sleek_storage package documentation for usage examples
```
