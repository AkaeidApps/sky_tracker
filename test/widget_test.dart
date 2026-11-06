// Basic smoke test for the SkyTrack app shell.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:sky_tracker/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // get_storage needs a documents directory; provide a temp one in tests.
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return Directory.systemTemp.path;
        });
    await GetStorage.init();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and verify the root navigator is created.
    await tester.pumpWidget(const SkyTrackApp());
    expect(find.byType(GetMaterialApp), findsOneWidget);

    // Let the splash screen timer and its exit transition complete.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
