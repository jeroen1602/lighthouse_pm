import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/OnExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/ShortcutExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/SleepExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/StandbyExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/LighthouseV2Device.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';

import '../../helpers/FailingBLEDevice.dart';
import '../../helpers/FakeBloc.dart';

void main() {
  test("Firmware should be unknown if verify hasn't run, LighthouseV2Device",
      () {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    expect(device.firmwareVersion, "UNKNOWN");

    LocalPlatform.overridePlatform = null;
  });

  test("Firmware should be known if verify has run, LighthouseV2Device",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.firmwareVersion, "FAKE_DEVICE");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to identify", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.SLEEP);

    //Now identify
    await device.identify();

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.ON, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not identify if characteristic is not found", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);

    //Now identify
    await device.identify();

    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection timeout, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    final device = LighthouseV2Device(lowLevelDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should handle connection error, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    lowLevelDevice.useTimeoutException = false;

    final device = LighthouseV2Device(lowLevelDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");

    LocalPlatform.overridePlatform = null;
  });

  test("Should have otherMetadata, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata['Channel'], "255");
    expect(otherMetadata['Model number'], "255");
    expect(otherMetadata['Serial number'], "255");
    expect(otherMetadata['Hardware revision'], "FAKE_REVISION");
    expect(otherMetadata['Manufacturer name'], "LIGHTHOUSE PM By Jeroen1602");

    LocalPlatform.overridePlatform = null;
  });

  test(
      "Should not crash when some secondary characteristics fail, LighthouseV2Device",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device =
        LighthouseV2Device(FailingV2DeviceOnSpecificCharacteristics(), bloc);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata, isNot(contains('Channel')));
    expect(otherMetadata, isNot(contains('Model number')));
    expect(otherMetadata, isNot(contains('Serial number')));
    expect(otherMetadata, isNot(contains('Hardware revision')));
    expect(otherMetadata, isNot(contains('Manufacturer name')));
    expect(otherMetadata, isEmpty);

    expect(device.firmwareVersion, "UNKNOWN");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not return valid if device isn't valid, LighthouseV2Device",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowDevice = CountingViveBaseStationDevice();
    final device = LighthouseV2Device(lowDevice, bloc);

    final valid = await device.isValid();
    expect(valid, false);

    expect(lowDevice.disconnectCount, 1);

    LocalPlatform.overridePlatform = null;
  });

  test('Should add Shortcut extension if enabled', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    bloc.settings.shortcutEnabled = true;
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(TypeMatcher<ShortcutExtension>()));

    LocalPlatform.overridePlatform = null;
  });

  test("Should not add Shortcut extension if platform is not Android",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.web;
    final bloc = FakeBloc.normal();
    bloc.settings.shortcutEnabled = true;
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    expect(device.deviceExtensions,
        isNot(contains(TypeMatcher<ShortcutExtension>())));

    LocalPlatform.overridePlatform = null;
  });

  test("Should add correct extensions, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    bloc.settings.shortcutEnabled = true;
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(TypeMatcher<ShortcutExtension>()));
    expect(device.deviceExtensions, contains(TypeMatcher<StandbyExtension>()));
    expect(device.deviceExtensions, contains(TypeMatcher<SleepExtension>()));
    expect(device.deviceExtensions, contains(TypeMatcher<OnExtension>()));

    LocalPlatform.overridePlatform = null;
  });

  test("Should return the correct device state", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final lut = {
      0x00: LighthousePowerState.SLEEP,
      0x01: LighthousePowerState.BOOTING,
      0x02: LighthousePowerState.STANDBY,
      0x08: LighthousePowerState.BOOTING,
      0x09: LighthousePowerState.BOOTING,
      0x0b: LighthousePowerState.ON,
    };

    for (int i = -0xFF; i < 0xFFE; i++) {
      final expectedState = lut[i] ?? LighthousePowerState.UNKNOWN;
      expect(device.powerStateFromByte(i), expectedState,
          reason:
              "State 0x${i.toRadixString(17).padLeft(2, '0')} should convert to $expectedState");
    }

    LocalPlatform.overridePlatform = null;
  });

  test("Should call disconnect if connection becomes lost", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final lowLevel = OfflineAbleLighthouseDevice(0, 0);
    final device = LighthouseV2Device(lowLevel, bloc);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    // Set the device in sleep mode (the hard way)
    (lowLevel.service.characteristics.firstWhere(
                (element) => element is FakeLighthouseV2PowerCharacteristic)
            as FakeLighthouseV2PowerCharacteristic)
        .data
      ..clear()
      ..add(0x00);

    var state = await device.getCurrentState();

    expect(state, 0x00, reason: "Device should be in sleep");
    lowLevel.currentState = LHBluetoothDeviceState.disconnected;

    // Should call disconnect and clean everything up.
    state = await device.getCurrentState();
    expect(state, isNull,
        reason: "Should not be able to get state if device is disconnected");
    expect(lowLevel.disconnectCount, 1,
        reason: "Should have called disconnected");

    LocalPlatform.overridePlatform = null;
  });

  test("Should not get state if characteristic is not set", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    final state = await device.getCurrentState();
    expect(state, isNull,
        reason: "Should not get state if characteristic is null");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from sleep to on, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.SLEEP);

    // Now turn it on
    await device.changeState(LighthousePowerState.ON);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.ON, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from sleep to standby, LighthouseV2Device",
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    var currentState = LighthousePowerState.UNKNOWN;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.SLEEP);

    // Now go to standby
    await device.changeState(LighthousePowerState.STANDBY);

    var first = LighthousePowerState.UNKNOWN;
    var second = LighthousePowerState.UNKNOWN;
    var third = LighthousePowerState.UNKNOWN;
    try {
      first =
          await getNextPowerState(device, currentState, Duration(seconds: 2));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      second = await getNextPowerState(device, first, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      third = await getNextPowerState(device, second, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }

    expect(first, LighthousePowerState.STANDBY,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.STANDBY,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test('Should be able to go from on to sleep, LighthouseV2Device', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.SLEEP);

    // Now turn it on
    await device.changeState(LighthousePowerState.ON);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.ON, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now go to sleep
    await device.changeState(LighthousePowerState.SLEEP);

    expect(await getNextPowerState(device, second, Duration(seconds: 1)),
        LighthousePowerState.SLEEP,
        reason: "Should directly switch to sleep");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test('Should be able to go from standby to sleep, LighthouseV2Device',
      () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    var currentState = LighthousePowerState.UNKNOWN;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.SLEEP);

    // Now go to standby
    await device.changeState(LighthousePowerState.STANDBY);

    var first = LighthousePowerState.UNKNOWN;
    var second = LighthousePowerState.UNKNOWN;
    var third = LighthousePowerState.UNKNOWN;
    try {
      first =
          await getNextPowerState(device, currentState, Duration(seconds: 2));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      second = await getNextPowerState(device, first, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      third = await getNextPowerState(device, second, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }

    expect(first, LighthousePowerState.STANDBY,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.STANDBY,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now go to sleep
    await device.changeState(LighthousePowerState.SLEEP);

    var last = LighthousePowerState.UNKNOWN;
    try {
      last = await getNextPowerState(device, third, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(last, LighthousePowerState.SLEEP,
        reason: "Should directly switch to sleep");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go form standby to on, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    var currentState = LighthousePowerState.UNKNOWN;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.SLEEP);

    // Now go to standby
    await device.changeState(LighthousePowerState.STANDBY);

    var first = LighthousePowerState.UNKNOWN;
    var second = LighthousePowerState.UNKNOWN;
    var third = LighthousePowerState.UNKNOWN;
    try {
      first =
          await getNextPowerState(device, currentState, Duration(seconds: 2));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      second = await getNextPowerState(device, first, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }
    try {
      third = await getNextPowerState(device, second, Duration(seconds: 3));
    } catch (e, s) {
      fail("$e, $s");
    }

    expect(first, LighthousePowerState.STANDBY,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.STANDBY,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now turn it on
    await device.changeState(LighthousePowerState.ON);

    var last = LighthousePowerState.UNKNOWN;
    try {
      last = await getNextPowerState(device, third, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(last, LighthousePowerState.ON,
        reason: "Should directly switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });

  test("Should be able to go from on to standby, LighthouseV2Device", () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final bloc = FakeBloc.normal();
    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), bloc);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.SLEEP);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.UNKNOWN, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.SLEEP);

    // Now turn it on
    await device.changeState(LighthousePowerState.ON);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.BOOTING,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.ON, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now turn it to standby
    await device.changeState(LighthousePowerState.STANDBY);

    expect(await getNextPowerState(device, second, Duration(seconds: 1)),
        LighthousePowerState.STANDBY,
        reason: "Should directly switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    LocalPlatform.overridePlatform = null;
  });
}

Future<LighthousePowerState> getNextPowerState(LighthouseDevice device,
    LighthousePowerState previous, Duration timeout) async {
  return device.powerStateEnum.firstWhere((element) => element != previous).timeout(timeout);
}
