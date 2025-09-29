![sleek_storage](https://raw.githubusercontent.com/IcySunStudio/sleek_storage/refs/heads/main/banner.png)

[![Pub](https://img.shields.io/pub/v/sleek_storage.svg?label=sleek_storage)](https://pub.dartlang.org/packages/sleek_storage)
[![License](https://img.shields.io/badge/License-BSD_3--Clause-green.svg)](https://opensource.org/licenses/BSD-3-Clause)

# Sleek Storage

**Fast. Simple. Reactive.**

A simple, reactive, and lightweight key-value store written in pure Dart. Features instant, synchronous reads, atomic file writes, and fully type-safe collections, all embracing the JSON serialization you already use in your app—no new formats, no codegen, no headaches.

On a Flutter project ? See [![Pub](https://img.shields.io/pub/v/sleek_storage.svg?label=sleek_storage_flutter)](https://pub.dartlang.org/packages/sleek_storage_flutter) that provides handy Flutter-specific initialization.

---

## Features

- **Simple & Reactive:**  
  Effortless key-value storage with instant reads and reactive streams for easy state management.

- **Type-safe Collections:**  
  All APIs are type-safe, supporting both default and custom converters. Use intuitive direct key-value access or an easy box/collection system for managing groups of objects.

- **JSON-native:**  
  Stores your data as JSON, reusing the serialization already present in most apps—no new formats, no code generation.

- **Memory-cached, Synchronous Reads:**  
  Loads all data in memory at startup for blazing-fast access. Great for small to medium datasets (see benchmarks).

- **Atomic, Batched Writes:**  
  Writes are grouped and performed atomically to avoid file corruption.

- **Lightweight:**  
  Pure Dart, minimal dependencies, and simple, auditable code. Works on all Flutter platforms (except Web, available soon).

- **Safe Initialization Options:**  
  Options to ensures safe startup and reads, for easy maintenance.

---

## Why Sleek Storage?

- **Built after reviewing 20+ packages** to address missing features and common pitfalls.
- **JSON is universal:** Most projects already use JSON for server data—why serialize local data differently?
- **Atomic file writes:** Prevents data corruption (unlike `shared_preferences` on some platforms).
- **Instant read performance:** Data is always in memory, reads are always synchronous.
- **Reactive streams:** Listen to changes on keys or collections, perfect for easy state management.
- **Inspired by the best:** Combines the simplicity of popular packages like [Hive CE](https://pub.dev/packages/hive_ce) and [shared_preferences](https://pub.dev/packages/shared_preferences), but with a focus on JSON-first storage and a reactive, type-safe API.

---

## Example

```dart
// Get storage instance (use your own path)
final storage = await SleekStorage.getInstance(Directory.systemTemp.path);

// Single value API (SleekValue)
final darkMode = storage.value<bool>('darkMode');
darkMode.set(true);
final isDark = darkMode.value;

// Listen to changes
darkMode.watch().listen((value) {
  print('Dark mode changed: $value');
});

// Type-safe box for users with custom converter
final usersBox = storage.box<User>(
  'users',
  fromJson: (json) => User.fromJson(json),
  toJson: (user) => user.toJson(),
);
usersBox.put('user1', User(name: 'Alice', age: 30));
final user = usersBox.get('user1');

// Get all users
final allUsers = usersBox.getAll();
```
---

## Batch Writes: Best Practices

**Avoid:**  
Do not use `await` inside a loop for writing multiple values, as this results in multiple separate file writes and poor performance.
This is true for all write operations, including `set`, `put`, `clear`,  `delete`, ...

```dart
// ❌ Inefficient: using `await put()` in a loop:
// Triggers a file write for every key
for (...) {
  await box.put(key, data);
}

// ✅ Efficient: using `putAll`:
// Writes all values in a single operation using putAll
await box.putAll({
  for (...) key: data,
});

// ✅ Efficient: using `put` without `await`: 
// Writes all values in memory, and wait next event loop to write them all at once
for (...) {
  box.put(key, data);
}
```

---

## Benchmarks
Tables shows write times, reload times, read times, and file sizes at different operation scales.

### 1,000 operations
| Competitor          | Write (ms) | Reload (ms) | Read (ms) | File Size (MB) |
|---------------------|------------|-------------|-----------|----------------|
| Sleek Storage       | 43         | 20          | 0         | 0.5 MB         |
| Shared Preferences  | 10366      | 0           | 0         | 0.5 MB         |
| Hive CE             | 22         | 22          | 1         | 0.4 MB         |
| Drift               | 265        | 0           | 111       | 0.4 MB         |

### 100,000 operations
| Competitor     | Write (ms) | Reload (ms) | Read (ms) | File Size (MB) |
|----------------|------------|-------------|-----------|----------------|
| Sleek Storage  | 1747       | 1599        | 12        | 50.2 MB        |
| Hive CE        | 485        | 377         | 88        | 43.4 MB        |
| Drift          | 1036       | 0           | 452       | 43.5 MB        |

### Stream performance, write-to-emit latency
This test measures the time taken from a write operation to the corresponding event being emitted on a watch stream.
A too long latency can lead to janky UI updates in reactive apps.
On modern desktop hardware, this is negligible for all competitors.

Results on an old Android 9 (Nokia 6) phone:

| Competitor     | Write-to-emit (ms)            |
|----------------|-------------------------------|
| Sleek Storage  | min: 0, max: 38, average: 4   |
| Hive CE        | min: 0, max: 20, average: 2   |
| Drift          | min: 7, max: 195, average: 28 |

### Bottom Line
Sleek Storage delivers performance that is comparable to Hive for most use cases. Hive still leads in raw speed for large datasets. Shared Preferences, however, falls significantly behind in write performance. Drift is somewhat in the middle, and has a quite low Stream performance.

**Notes:**
- Tested on June 2025, on Windows 11, with an AMD 3900X CPU and NVMe SSD drive.
- Data used is an advanced JSON object with different types, including nested objects and lists.
- Reload time is the time taken to read all data from disk into memory (usually done at app startup).
- Uses batched writes when available.
- Code is available in the benchmark folder.

** Limitations:**
- Due to the structure of Sleek Storage, writing a single item in a large collection take the same time as writing them all at once. But if you don't await write operations, this is not a problem in practice.
- On modern desktop hardware, Sleek Storage is very fast, but you should keep store size under 50,000 items for best performance.
- On old Android hardware, Sleek Storage is still fast, but you should keep store size under 10,000 items.

---

## Limitations

- **Not designed for multi-thread/isolate use:** For simplicity and speed, Sleek Storage is optimized for main isolate usage only.
- **Not for huge datasets:** Loads all data into memory for speed. See benchmark to determine if it fits your use case.
- **Currently not compatible with web** (uses `dart:io`).

---

## Alternatives & Design Rationale

A thorough study was conducted in June 2025, comparing over 20 Dart and Flutter storage solutions to design Sleek Storage with the best features and minimal drawbacks. Here’s how Sleek Storage compares to some and why it was created:

- **[Hive CE](https://pub.dev/packages/hive_ce):** Fast and full-featured, but uses a custom binary format and codegen; Sleek Storage focuses on pure JSON, no codegen, and a simpler, type-safe API.
- **[shared_preferences](https://pub.dev/packages/shared_preferences):** Popular and stable, but not reactive, not designed for collections or complex objects, and not always atomic—data corruption is possible on some platforms.
- **[tiny_storage](https://pub.dev/packages/tiny_storage):** Small, easy and synchronous, but not reactive.
- **[prf](https://pub.dev/packages/prf):** Type-safe and modern, but not reactive and async API; based on `shared_preferences`.
- **[json_store](https://pub.dev/packages/json_store):** JSON-based, but aging, and depends on `sqflite` & `secure_storage`.
- **[json_bridge](https://pub.dev/packages/json_bridge):** Manipulates nested keys in JSON, but outdated and minimal features.
- **[binary_map_file](https://pub.dev/packages/binary_map_file):** Synchronous and simple, but manual file saving.
- **[lite_storage](https://pub.dev/packages/lite_storage):** Synchronous and dependency-free, but API is too basic.
- **[flexi_storage](https://pub.dev/packages/flexi_storage):** Flexible and supports batch ops, but fully async and not reactive.
- **[orange](https://pub.dev/packages/orange):** Promises fast performance and simplicity, but has limited features, built on `Sembast`.
- **[get_storage](https://pub.dev/packages/get_storage):** Simple and synchronous, with callbacks for reactivity (no Streams). However, it depends on `GetX`, and it is old and looks abandoned.

**Summary:**  
Sleek Storage is JSON-first, type-safe, reactive, atomic, synchronous and lightweight package, with minimal dependencies—combining the strengths of the best existing packages, while addressing their shortcomings.

---
🏆 **Sleek Storage is the missing piece for easy local storage in Dart !**
