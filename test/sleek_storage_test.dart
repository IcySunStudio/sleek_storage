import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

import 'package:sleek_storage/sleek_storage.dart';

void main() async {
  Future<SleekStorage> setUp({bool deleteFileFirst = true}) async {
    final path = Directory.systemTemp.path;
    if (deleteFileFirst) {
      await SleekStorage.deleteStorage(path);
    }
    return await SleekStorage.getInstance(path);
  }

  // Tests
  group('Basic tests', () {
    const intValue = 42;
    test('Box', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

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
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      value = box.get('key1');
      expect(value, intValue);
    });
    test('Value', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

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
      storage = await setUp(deleteFileFirst: false);
      holder = storage.value<int>(name);
      value = holder.value;
      expect(value, intValue);
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

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;  // Wait until the value is saved

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<int>(name);
      expect(box.get('key1'), intValue);
      expect(box.get('key2'), intValue);
      expect(box.get('key3'), intValue);

      // Ensure that only one save was triggered
      expect(saveCount, 1);
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
    });
  });

  group('Advanced tests', () {
    test('Complex object', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'objectBox';
      var box = storage.box<MyClass>(name, fromJson: (json) => MyClass.fromJson(json), toJson: (obj) => obj.toJson());

      // Add value
      final myObject = MyClass.random(1);
      box.put('key1', myObject);
      var value = box.get('key1');
      expect(value, myObject);

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future;  // Wait until the value is saved

      // Check if the value is saved correctly
      storage = await setUp(deleteFileFirst: false);
      box = storage.box<MyClass>(name, fromJson: (json) => MyClass.fromJson(json), toJson: (obj) => obj.toJson());
      value = box.get('key1');
      expect(value, myObject);
    });
    test('List of complex objects', () async {
      // Create a SleekStorage instance
      var storage = await setUp();

      // Open box
      const name = 'objectBox';
      var box = storage.box<MyClass>(name, fromJson: (json) => MyClass.fromJson(json), toJson: (obj) => obj.toJson());

      // Add value
      const length = 10000;
      final myList = List.generate(length, MyClass.random);
      for (var i = 0; i < myList.length; i++) {
        final myObject = myList[i];
        box.put(myObject.string, myObject);
      }

      // Wait for the value to be written to disk
      final completer = Completer<void>();
      storage.lastSavedAt.listen((_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
      var stopwatch = Stopwatch()..start();
      await completer.future;  // Wait until the value is saved
      print('Time taken to save $length objects: ${stopwatch.elapsedMilliseconds} ms');

      // Check if the value is saved correctly
      stopwatch = Stopwatch()..start();
      storage = await setUp(deleteFileFirst: false);
      print('Time taken to load storage: ${stopwatch.elapsedMilliseconds} ms');

      stopwatch = Stopwatch()..start();
      box = storage.box<MyClass>(name, fromJson: (json) => MyClass.fromJson(json), toJson: (obj) => obj.toJson());
      print('Time taken to open box: ${stopwatch.elapsedMilliseconds} ms');

      final readList = <MyClass>[];
      for (final key in box.keys) {
        readList.add(box.get(key)!);
      }
      expect(iterableEquals(myList, readList), true);
    });
  });
}


class MyClass {
  const MyClass({
    required this.string,
    required this.number,
    required this.doubleValue,
    required this.boolean,
    this.nullValue,
    required this.list,
    required this.nested,
  });
  factory MyClass.fromJson(Map<String, dynamic> json) => MyClass(
    string: json['string'] as String,
    number: json['number'] as int,
    doubleValue: (json['double'] as num).toDouble(),
    boolean: json['boolean'] as bool,
    nullValue: json['nullValue'],
    list: (json['list'] as List)
        .map((e) => ListItem.fromJson(e))
        .toList(),
    nested: Nested.fromJson(json['nested'] as Map<String, dynamic>),
  );

  static MyClass random(int index) => MyClass(
    string: 'hello$index',
    number: 40 + index,
    doubleValue: 3.0 + index * 0.1,
    boolean: index % 2 == 0,
    nullValue: index % 3 == 0 ? null : 'notNull$index',
    list: List.generate(12, (i) => ListItem(value: 'item${i + 1}_$index')),
    nested: Nested(
      innerString: 'world$index',
      innerList: List.generate(3, (i) => i + index),
      innerMap: InnerMap(
        flag: index % 2 == 1,
        value: index % 4 == 0 ? null : 'value$index',
      ),
    ),
  );

  final String string;
  final int number;
  final double doubleValue;
  final bool boolean;
  final dynamic nullValue;
  final List<ListItem> list;
  final Nested nested;

  Map<String, dynamic> toJson() => {
    'string': string,
    'number': number,
    'double': doubleValue,
    'boolean': boolean,
    'nullValue': nullValue,
    'list': list.map((e) => e.toJson()).toList(),
    'nested': nested.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MyClass &&
              runtimeType == other.runtimeType &&
              string == other.string &&
              number == other.number &&
              doubleValue == other.doubleValue &&
              boolean == other.boolean &&
              nullValue == other.nullValue &&
              iterableEquals(list, other.list) &&
              nested == other.nested;

  @override
  int get hashCode =>
      string.hashCode ^
      number.hashCode ^
      doubleValue.hashCode ^
      boolean.hashCode ^
      nullValue.hashCode ^
      list.hashCode ^
      nested.hashCode;
}

class ListItem {
  const ListItem({
    required this.value,
  });
  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
    value: json['value'] as String,
  );

  final String value;

  Map<String, dynamic> toJson() => {
    'value': value,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ListItem &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class NestedMap {
  const NestedMap({required this.nestedMap});
  factory NestedMap.fromJson(Map<String, dynamic> json) => NestedMap(nestedMap: json['nestedMap'] as String);

  final String nestedMap;

  Map<String, dynamic> toJson() => {'nestedMap': nestedMap};
}

class Nested {
  const Nested({
    required this.innerString,
    required this.innerList,
    required this.innerMap,
  });
  factory Nested.fromJson(Map<String, dynamic> json) => Nested(
    innerString: json['innerString'] as String,
    innerList: (json['innerList'] as List).map((e) => e as int).toList(),
    innerMap: InnerMap.fromJson(json['innerMap'] as Map<String, dynamic>),
  );

  final String innerString;
  final List<int> innerList;
  final InnerMap innerMap;

  Map<String, dynamic> toJson() => {
    'innerString': innerString,
    'innerList': innerList,
    'innerMap': innerMap.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Nested &&
              runtimeType == other.runtimeType &&
              innerString == other.innerString &&
              iterableEquals(innerList, other.innerList) &&
              innerMap == other.innerMap;

  @override
  int get hashCode =>
      innerString.hashCode ^
      innerList.hashCode ^
      innerMap.hashCode;
}

class InnerMap {
  const InnerMap({required this.flag, this.value});
  factory InnerMap.fromJson(Map<String, dynamic> json) => InnerMap(
    flag: json['flag'] as bool,
    value: json['value'],
  );

  final bool flag;
  final dynamic value;

  Map<String, dynamic> toJson() => {
    'flag': flag,
    'value': value,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InnerMap &&
              runtimeType == other.runtimeType &&
              flag == other.flag &&
              value == other.value;

  @override
  int get hashCode => flag.hashCode ^ value.hashCode;
}

/// Compares two iterables for deep equality.
/// Copied from flutter's listEquals()
///
/// Returns true if the iterables are both null, or if they are both non-null, have
/// the same length, and contain the same members in the same order. Returns
/// false otherwise.
///
/// The term "deep" above refers to the first level of equality: if the elements
/// are maps, lists, sets, or other collections/composite objects, then the
/// values of those elements are not compared element by element unless their
/// equality operators ([Object.operator==]) do so.
bool iterableEquals<T>(Iterable<T>? a, Iterable<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  final ita = a.iterator;
  final itb = b.iterator;
  while (ita.moveNext() && itb.moveNext()) {
    if (ita.current != itb.current) return false;
  }
  return true;
}
