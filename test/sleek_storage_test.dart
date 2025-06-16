import 'dart:io';

import 'package:test/test.dart';

import 'package:sleek_storage/sleek_storage.dart';

void main() {
  final testDir = Directory.systemTemp;

  // Tests
  test('Open box', () async {
    final storage = await SleekStorage.getInstance(testDir.path);
    final box = storage.box<int>('testBox');

    expect(box.name, 'testBox');
  });
}
