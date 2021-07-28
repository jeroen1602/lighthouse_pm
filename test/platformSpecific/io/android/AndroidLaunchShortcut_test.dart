import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';
import 'package:lighthouse_pm/platformSpecific/io/android/androidLauncherShortcut/io.dart';
import 'package:lighthouse_pm/platformSpecific/io/android/androidLauncherShortcut/shared.dart';
import 'package:lighthouse_pm/platformSpecific/io/android/androidLauncherShortcut/unsupported.dart'
    as unsupported;

void main() {
  test('Should not work on non Android platform', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.unsupported;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    LocalPlatform.overridePlatform = PlatformOverride.ios;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    LocalPlatform.overridePlatform = PlatformOverride.web;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    LocalPlatform.overridePlatform = PlatformOverride.linux;
    try {
      AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!\nHow come the class is still initialized?');
    }

    LocalPlatform.overridePlatform = null;
  });

  test('Unsupported should throw errors', () async {
    try {
      unsupported.AndroidLauncherShortcut.instance;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
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
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }

    try {
      await instance.changePowerStateMac.first;
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }

    try {
      await instance.requestShortcutLighthouse("00:00:00:00:00:00", "Name");
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<UnsupportedError>());
      expect((e as UnsupportedError).message,
          'Hey developer this platform doesn\'t support shortcuts!');
    }
  });

  test('Should return shortcuts supported', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = AndroidLauncherShortcut.instance;

    AndroidLauncherShortcut.channel.setMockMethodCallHandler((call) async {
      if (call.method == 'supportShortcut') {
        return true;
      }
    });

    expect(await instance.shortcutSupported(), isTrue);

    AndroidLauncherShortcut.channel.setMockMethodCallHandler((call) async {
      if (call.method == 'supportShortcut') {
        return false;
      }
    });

    expect(await instance.shortcutSupported(), isFalse);

    AndroidLauncherShortcut.channel.setMockMethodCallHandler((call) async {
      if (call.method == 'supportShortcut') {
        return "something";
      }
    });

    expect(await instance.shortcutSupported(), isFalse);

    AndroidLauncherShortcut.channel.setMockMethodCallHandler(null);
    LocalPlatform.overridePlatform = null;
  });

  test('Should handle ready for data', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = AndroidLauncherShortcut.instance;

    int readyForDataCalled = 0;

    AndroidLauncherShortcut.channel.setMockMethodCallHandler((call) async {
      if (call.method == 'readyForData') {
        readyForDataCalled++;
        return;
      }
    });

    await instance.readyForData();

    expect(readyForDataCalled, 1);

    AndroidLauncherShortcut.channel.setMockMethodCallHandler(null);
    LocalPlatform.overridePlatform = null;
  });

  test('Should handle mac shortcuts', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = AndroidLauncherShortcut.instance;
    instance.clearStateStream();

    await AndroidLauncherShortcut.messageHandler(
        MethodCall('handleMacShortcut', '00:00:00:00:00:00'));

    final stateChange = await instance.changePowerStateMac.first;
    expect(stateChange, isNotNull);
    expect(stateChange!.data, '00:00:00:00:00:00');
    expect(stateChange.type, ShortcutTypes.MAC_TYPE);

    instance.clearStateStream();
    LocalPlatform.overridePlatform = null;
  });

  test('Should not handle mac shortcuts with incorrect data', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = AndroidLauncherShortcut.instance;
    instance.clearStateStream();

    await AndroidLauncherShortcut.messageHandler(
        MethodCall('handleMacShortcut', 12345));

    try {
      final stateChange = await instance.changePowerStateMac.first
          .timeout(Duration(seconds: 1));
      print(stateChange);
      fail('Should timeout');
    } catch (e) {
      expect(e, TypeMatcher<TimeoutException>());
    }

    LocalPlatform.overridePlatform = null;
  });

  test('Should not handle unsupported method', () async {
    WidgetsFlutterBinding.ensureInitialized();
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = AndroidLauncherShortcut.instance;

    try {
      await AndroidLauncherShortcut.messageHandler(
          MethodCall('unsupportedMethod'));
      fail('Should fail');
    } catch (e) {
      expect(e, TypeMatcher<NoSuchMethodError>());
      expect(e.toString(), contains('unsupportedMethod'));
      expect(e.toString(), contains('AndroidLauncherShortcut'));
    }

    LocalPlatform.overridePlatform = null;
  });

  test('Shortcut handle to string should work', () {
    final handle = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');

    expect(handle.toString(), 'ShortcutHandle: {"type": "mac", "data": "Data"}');
  });

  test('Shortcut handle should compare', () {
    final handle1 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');
    final handle2 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');

    expect(handle1, handle2);

    final handle3 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'data');
    expect(handle1, isNot(handle3));

    // TODO: change type if others become available.
    // final handle4 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');
    // expect(handle1, isNot(handle4));

    final otherObject = "Wow";
    expect(handle1, isNot(otherObject));
  });

  test('Shortcut handle should generate hashcode', () {
    final handle1 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');
    final handle2 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'Data');


    // Same objects should have the same hashcode
    expect(handle1.hashCode, handle2.hashCode);

    final handle3 = ShortcutHandle(ShortcutTypes.MAC_TYPE, 'data');

    // Different objects should not have the same hashcode
    expect(handle1.hashCode, isNot(handle3.hashCode));
  });
}
