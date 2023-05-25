import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut_io.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut_shared.dart';
import 'package:lighthouse_pm/platform_specific/mobile/android/android_launcher_shortcut/android_launcher_shortcut_unsupported.dart'
    as unsupported;
import 'package:shared_platform/shared_platform_io.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should not work on non Android platform', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    SharedPlatform.overridePlatform = PlatformOverride.ios;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    SharedPlatform.overridePlatform = PlatformOverride.web;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    SharedPlatform.overridePlatform = PlatformOverride.linux;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }
  });

  test('Unsupported should throw errors', () async {
    try {
      unsupported.AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    final instance = unsupported.AndroidLauncherShortcut.testing();

    expect(await instance.shortcutSupported(), isFalse,
        reason: 'Should not support shortcuts');

    try {
      await instance.readyForData();
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }

    try {
      await instance.changePowerStateMac.first;
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }

    try {
      await instance.requestShortcutLighthouse("00:00:00:00:00:00", "Name");
      fail('Should fail');
    } catch (e) {
      expect(e, isA<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }
  });

  test('Should return shortcuts supported', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final instance = AndroidLauncherShortcut.instance;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel,
            (final call) async {
      if (call.method == 'supportShortcut') {
        return true;
      }
      return null;
    });

    expect(await instance.shortcutSupported(), isTrue);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel,
            (final call) async {
      if (call.method == 'supportShortcut') {
        return false;
      }
      return null;
    });

    expect(await instance.shortcutSupported(), isFalse);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel,
            (final call) async {
      if (call.method == 'supportShortcut') {
        return "something";
      }
      return null;
    });

    expect(await instance.shortcutSupported(), isFalse);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel, null);
  });

  test('Should handle ready for data', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final instance = AndroidLauncherShortcut.instance;

    int readyForDataCalled = 0;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel,
            (final call) async {
      if (call.method == 'readyForData') {
        readyForDataCalled++;
        return;
      }
      return null;
    });

    await instance.readyForData();

    expect(readyForDataCalled, 1);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidLauncherShortcut.channel, null);
  });

  test('Should handle mac shortcuts', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final instance = AndroidLauncherShortcut.instance;
    instance.clearStateStream();

    await AndroidLauncherShortcut.messageHandler(
        const MethodCall('handleMacShortcut', '00:00:00:00:00:00'));

    final stateChange = await instance.changePowerStateMac.first;
    expect(stateChange, isNotNull);
    expect(stateChange!.data, '00:00:00:00:00:00');
    expect(stateChange.type, ShortcutTypes.macType);

    instance.clearStateStream();
  });

  test('Should not handle mac shortcuts with incorrect data', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final instance = AndroidLauncherShortcut.instance;
    instance.clearStateStream();

    await AndroidLauncherShortcut.messageHandler(
        const MethodCall('handleMacShortcut', 12345));

    try {
      final stateChange = await instance.changePowerStateMac.first
          .timeout(const Duration(seconds: 1));
      debugPrint('$stateChange');
      fail('Should timeout');
    } catch (e) {
      expect(e, isA<TimeoutException>());
    }
  });

  test('Should not handle unsupported method', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      await AndroidLauncherShortcut.messageHandler(
          const MethodCall('unsupportedMethod'));
      fail('Should fail');
    } catch (e) {
      expect(e, isA<NoSuchMethodError>());
      expect(e.toString(), contains('unsupportedMethod'));
      expect(e.toString(), contains('AndroidLauncherShortcut'));
    }
  });

  test('Shortcut handle to string should work', () {
    const handle = ShortcutHandle(ShortcutTypes.macType, 'Data');

    expect(
        handle.toString(), 'ShortcutHandle: {"type": "mac", "data": "Data"}');
  });

  test('Shortcut handle should compare', () {
    const handle1 = ShortcutHandle(ShortcutTypes.macType, 'Data');
    const handle2 = ShortcutHandle(ShortcutTypes.macType, 'Data');

    expect(handle1, handle2);

    const handle3 = ShortcutHandle(ShortcutTypes.macType, 'data');
    expect(handle1, isNot(handle3));

    // TODO: change type if others become available.
    // final handle4 = ShortcutHandle(ShortcutTypes.macType, 'Data');
    // expect(handle1, isNot(handle4));

    const otherObject = "Wow";
    expect(handle1, isNot(otherObject));
  });

  test('Shortcut handle should generate hashcode', () {
    const handle1 = ShortcutHandle(ShortcutTypes.macType, 'Data');
    const handle2 = ShortcutHandle(ShortcutTypes.macType, 'Data');

    // Same objects should have the same hashcode
    expect(handle1.hashCode, handle2.hashCode);

    const handle3 = ShortcutHandle(ShortcutTypes.macType, 'data');

    // Different objects should not have the same hashcode
    expect(handle1.hashCode, isNot(handle3.hashCode));
  });
}
