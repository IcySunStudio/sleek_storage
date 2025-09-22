import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import 'package:sleek_storage/sleek_storage.dart';

import 'models/basic.dart';
import 'models/nested.dart';

void main() async {
  group('Basic tests', () {
    const intValue = 42;
    test('Value', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Create value holder
      const name = 'myInt';
      var holder = storage.value<int>(name);
      expect(holder.key, name);
      expect(holder.value, isNull);

      // Set value
      final future = holder.set(intValue);

      // Ensure the value is set immediately
      var value = holder.value;
      expect(value, intValue);

      // Wait for the value to be written to disk
      await future;

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      holder = storage.value<int>(name);
      value = holder.value;
      expect(value, intValue);
    });
    test('Value with defaultValue', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Create value holder
      const name = 'myInt';
      var holder = storage.value<int>(name, defaultValue: intValue);
      expect(holder.key, name);
      expect(holder.value, intValue);
    });
    test('Box', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add value
      final future = box.put('key1', intValue);

      // Ensure the value is set immediately
      var value = box.get('key1');
      expect(value, intValue);

      // Wait for the value to be written to disk
      await future;

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      value = box.get('key1');
      expect(value, intValue);
    });
    test('Box index operator', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add value
      box['key1'] = intValue;

      // Ensure the value is set immediately
      var value = box['key1'];
      expect(value, intValue);

      // Wait for values to be written to disk
      await storage.lastSavedAt.next;
    });
    test('Box.putAll' , () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add values
      final future = box.putAll({'key1': intValue, 'key2': intValue, 'key3': intValue});

      // Ensure the values are set immediately
      expect(box.get('key1'), intValue);
      expect(box.get('key2'), intValue);
      expect(box.get('key3'), intValue);

      // Wait for the values to be written to disk
      await future;

      // Check if the values are saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      expect(box.get('key1'), intValue);
      expect(box.get('key2'), intValue);
      expect(box.get('key3'), intValue);
    });
    test('Box.delete(key)', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'testBox';
      var box = storage.box<int>(name);
      expect(box.key, name);

      // Add value
      const key = 'key1';
      box.put(key, intValue);

      // Ensure the value is set immediately
      expect(box.get(key), intValue);

      // Listen to changes
      expectLater(box.watch(key).innerStream, emitsInOrder([null]));

      // Delete value
      final future = box.delete(key);

      // Wait for the value to be deleted from disk
      await future;

      // Check if the value is deleted correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      expect(box.get(key), isNull);
    });
    test('Multiple grouped modifications', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

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

      // Wait for values to be written to disk
      await storage.lastSavedAt.next;
      // Ensure no additional saves were triggered
      await Future.delayed(const Duration(seconds: 1));

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      expect(box.get('key1'), intValue);
      expect(box.get('key2'), intValue);
      expect(box.get('key3'), intValue);

      // Ensure that only one save was triggered
      expect(saveCount, 1);
    });
    test('Box enumeration reflects live changes', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'testBox';
      final box = storage.box<BasicClass>(name, fromJson: (key, json) => BasicClass.fromJson(json));

      // Populate box with basic objects with same internal value
      for (var i = 0; i < 10; i++) {
        final obj = BasicClass('$i', intValue);
        box.put(obj.id, obj);
      }
      expect(box.get('5')?.value, intValue);

      // Enumerate
      const newIntValue = 51;
      for (final obj in box) {
        // Simulate some processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Change one value AHEAD of iteration
        if (obj.id == '1') {
          final newObj = BasicClass('5', newIntValue);
          box.put(newObj.id, newObj);
        }

        // Once iteration reaches the changed object, check if it's changed
        else if (obj.id == '5') {
          // Check if the value is changed correctly
          expect(obj.value, newIntValue);
        }
      }
    });
    test('Box.watch', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

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

      // Wait for the value to be written to disk (avoid consecutive tests issues)
      await storage.lastSavedAt.next;
    });
    test('getAllValuesKeys and getAllBoxesKeys', () async {
      var storage = await setUp();
      storage.value<int>('val1').set(1);
      storage.value<int>('val2').set(2);
      storage.box<String>('box1').put('k', 'v');
      await storage.lastSavedAt.next;

      expect(storage.getAllValuesKeys(), containsAll(['val1', 'val2']));
      expect(storage.getAllBoxesKeys(), contains('box1'));
    });
    test('clear storage', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Add some data
      storage.value<int>('val1').set(1);
      storage.box<String>('box1').put('k', 'v');

      // Wait for the value to be written to disk
      await storage.lastSavedAt.next;

      // Ensure data is present in memory
      expect(storage.getAllValuesKeys(), contains('val1'));
      expect(storage.getAllBoxesKeys(), contains('box1'));

      // Clear storage
      await storage.clear();

      // Ensure data is cleared in memory
      for (final key in storage.getAllValuesKeys()) {
        expect(storage.value(key).value, isNull);
      }
      for (final key in storage.getAllBoxesKeys()) {
        expect(storage.box(key).isEmpty, true);
      }

      // Reload storage from disk
      storage = await setUp(deleteFileFirst: false);

      // Ensure data is cleared on disk
      for (final key in storage.getAllValuesKeys()) {
        expect(storage.value(key).value, isNull);
      }
      for (final key in storage.getAllBoxesKeys()) {
        expect(storage.box(key).isEmpty, true);
      }
    });
    test('close releases resources', () async {
      var storage = await setUp();
      await storage.close();
      expect(() => storage.lastSavedAt.add(DateTime.now()), throwsA(isA<StateError>()));
    });
    test('concurrent flush calls do not corrupt data', () async {
      var storage = await setUp();
      storage.value<int>('val').set(1);
      // Call flush twice in quick succession
      await Future.wait([storage.flush(), storage.flush()]);
      var storage2 = await setUp(deleteFileFirst: false);
      expect(storage2.value<int>('val').value, 1);
    });
    test('concurrent flush triggers correct number of writes', () async {
      var storage = await setUp();
      storage.value<int>('val').set(1);

      var saveCount = 0;
      storage.lastSavedAt.listen((_) => saveCount++);

      // Start flushes at the same time
      await Future.wait([
        storage.flush(),
        storage.flush(),
        storage.flush(),
        storage.flush(),
      ]);

      // Should have saved once
      await Future.delayed(Duration.zero);    // Ensure lastSavedAt is updated (next event loop)
      expect(saveCount, 1);

      // Flush again just once
      saveCount = 0;
      await storage.flush();
      await Future.delayed(Duration.zero);    // Ensure lastSavedAt is updated (next event loop)
      expect(saveCount, 1);

      // Start 3 consecutive flushes: should save only twice: one for the first, one for the queued flush
      saveCount = 0;
      await Future.wait([
        storage.flush(),
        Future.delayed(Duration.zero, storage.flush),
        Future.delayed(Duration.zero, storage.flush),
      ]);
      await Future.delayed(Duration.zero);    // Ensure lastSavedAt is updated (next event loop)
      expect(saveCount, 2);
    });
  });
  group('Advanced tests', () {
    test('Complex object', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'objectBox';
      var box = storage.box<MyClass>(name, fromJson: (key, json) => MyClass.fromJson(json));

      // Add value
      final myObject = MyClass.random(1);
      final future = box.put('key1', myObject);

      // Ensure the value is set immediately
      var value = box.get('key1');
      expect(value, myObject);

      // Wait for the value to be written to disk
      await future;

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<MyClass>(name, fromJson: (key, json) => MyClass.fromJson(json));
      value = box.get('key1');
      expect(value, myObject);
    });
    test('List of complex objects', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'objectBox';
      var box = storage.box<MyClass>(name, fromJson: (key, json) => MyClass.fromJson(json));

      // Add value
      const length = 10000;
      final myList = List.generate(length, MyClass.random);
      for (var i = 0; i < myList.length; i++) {
        final myObject = myList[i];
        box.put(myObject.string, myObject);
      }

      // Wait for the value to be written to disk
      var stopwatch = Stopwatch()..start();
      await storage.lastSavedAt.next;
      print('Time taken to save $length objects: ${stopwatch.elapsedMilliseconds} ms');

      // Check if the value is saved correctly
      stopwatch = Stopwatch()..start();
      storage = await setUp(deleteFileFirst: false);
      print('Time taken to load storage: ${stopwatch.elapsedMilliseconds} ms');

      stopwatch = Stopwatch()..start();
      box = storage.box<MyClass>(name, fromJson: (key, json) => MyClass.fromJson(json));
      print('Time taken to open box: ${stopwatch.elapsedMilliseconds} ms');

      final readList = <MyClass>[];
      for (final key in box.keys) {
        readList.add(box.get(key)!);
      }
      expect(iterableEquals(myList, readList), true);
    });
  });
}

Future<SleekStorage> setUp({bool deleteFileFirst = true}) async {
  final path = Directory.systemTemp.path;
  if (deleteFileFirst) {
    await SleekStorage.deleteStorage(path);
  }
  return await SleekStorage.getInstance(path);
}
