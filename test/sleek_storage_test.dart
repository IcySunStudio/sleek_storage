import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import 'package:sleek_storage/sleek_storage.dart';

void main() async {
  final testDir = Directory.systemTemp;

  // Tests
  group('Tests', () {
    const intValue = 42;
    test('Box', () async {
      // Create a SleekStorage instance
      var storage = await SleekStorage.getInstance(testDir.path);

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add value
      box.put('key1', intValue);
      var value = box.get('key1');
      expect(value, intValue);

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;  // Wait until the value is saved

      // Check if the value is saved correctly
      storage = await SleekStorage.getInstance(testDir.path);
      box = storage.box<int>(name);
      value = box.get('key1');
      expect(value, intValue);
    });
    test('Value', () async {
      // Create a SleekStorage instance
      var storage = await SleekStorage.getInstance(testDir.path);

      // Create value holder
      const name = 'myInt';
      var holder = storage.value<int>(name);
      expect(holder.key, name);

      // Set value
      holder.set(intValue);
      var value = holder.value;
      expect(value, intValue);

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;  // Wait until the value is saved

      // Check if the value is saved correctly
      storage = await SleekStorage.getInstance(testDir.path);
      holder = storage.value<int>(name);
      value = holder.value;
      expect(value, intValue);
    });
    test('Multiple grouped modifications', () async {
      // Create a SleekStorage instance
      var storage = await SleekStorage.getInstance(testDir.path);

      // Listen to storage saves
      var saveCount = 0;
      storage.lastSavedAt.listen((event) => saveCount++);

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add value
      box.put('key1', intValue);
      box.put('key2', intValue);
      box.put('key3', intValue);

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;  // Wait until the value is saved

      // Check if the value is saved correctly
      storage = await SleekStorage.getInstance(testDir.path);
      box = storage.box<int>(name);
      expect(box.get('key1'), intValue);
      expect(box.get('key2'), intValue);
      expect(box.get('key3'), intValue);

      // Ensure that only one save was triggered
      expect(saveCount, 1);
    });
    test('Box.watch', () async {
      // Create a SleekStorage instance
      var storage = await SleekStorage.getInstance(testDir.path);

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add first value
      box.put('key1', 40);

      // Listen to changes
      expectLater(box.watch('key1').innerStream, emitsInOrder([50, 51]));

      // Change value
      box.put('key1', 50);
      box.put('key1', 51);
    });
  });
}
