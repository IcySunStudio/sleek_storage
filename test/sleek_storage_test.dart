import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sleek_storage/sleek_storage.dart';

void main() {
  // Initialize the Flutter test environment
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the path_provider plugin to return a fixed directory
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return Platform.environment['temp'];
      }
      return null;
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  // Tests
  test('Open box', () async {
    final storage = await SleekStorage.getInstance();
    final box = storage.box<int>('testBox');

    expect(box.name, 'testBox');
  });
}
