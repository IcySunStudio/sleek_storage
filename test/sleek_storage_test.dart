import 'dart:io';

import 'package:test/test.dart';

import 'package:sleek_storage/sleek_storage.dart';

void main() async {
  final testDir = Directory.systemTemp;

  // Tests
  group('Test', () {
    const intValue = 42;
    test('Test Box', () async {
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

      // Check if the value is saved correctly
      await Future.delayed(const Duration(seconds: 1));
      storage = await SleekStorage.getInstance(testDir.path);
      box = storage.box<int>(name);
      value = box.get('key1');
      expect(value, intValue);
    });
    test('Test Value', () async {
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

      // Check if the value is saved correctly
      await Future.delayed(const Duration(seconds: 1));
      storage = await SleekStorage.getInstance(testDir.path);
      holder = storage.value<int>(name);
      value = holder.value;
      expect(value, intValue);
    });
  });
}
