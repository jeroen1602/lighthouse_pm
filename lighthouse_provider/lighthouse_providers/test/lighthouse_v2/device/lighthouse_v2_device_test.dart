import 'dart:async';

import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

import '../../helpers/failing_ble_device.dart';
import '../../helpers/fake_bloc.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test("Firmware should be unknown if verify hasn't run, LighthouseV2Device",
      () {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    expect(device.firmwareVersion, "UNKNOWN");
  });

  test("Firmware should be known if verify has run, LighthouseV2Device",
      () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    expect(device.firmwareVersion, "FAKE_DEVICE");
  });

  test("Should be able to identify", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.unknown, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.sleep);

    //Now identify
    await device.identify();

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.on, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should not identify if characteristic is not found", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);

    //Now identify
    await device.identify();

    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should handle connection timeout, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    final device = LighthouseV2Device(lowLevelDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");
  });

  test("Should handle connection error, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final lowLevelDevice = FailingBLEDeviceOnConnect();
    lowLevelDevice.useTimeoutException = false;

    final device = LighthouseV2Device(lowLevelDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false,
        reason: "Device should not be valid if no connection can take place");
  });

  test("Should have otherMetadata, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);

    final otherMetadata = device.otherMetadata;

    expect(otherMetadata['Channel'], "255");
    expect(otherMetadata['Model number'], "255");
    expect(otherMetadata['Serial number'], "255");
    expect(otherMetadata['Hardware revision'], "FAKE_REVISION");
    expect(otherMetadata['Manufacturer name'], "LIGHTHOUSE PM By Jeroen1602");
  });

  test(
      "Should not crash when some secondary characteristics fail, LighthouseV2Device",
      () async {
    final persistence = FakeLighthouseV2Bloc();
    final device = LighthouseV2Device(
        FailingV2DeviceOnSpecificCharacteristics(), persistence);

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
  });

  test("Should not return valid if device isn't valid, LighthouseV2Device",
      () async {
    final persistence = FakeLighthouseV2Bloc();
    final lowDevice = CountingViveBaseStationDevice();
    final device = LighthouseV2Device(lowDevice, persistence);

    final valid = await device.isValid();
    expect(valid, false);

    expect(lowDevice.disconnectCount, 1);
  });

  test('Should add Shortcut extension if enabled', () async {
    final persistence = FakeLighthouseV2Bloc();
    persistence.shortcutsEnabled = true;
    final device = LighthouseV2Device(
        FakeLighthouseV2Device(0, 0), persistence, (mac, name) {});

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(isA<ShortcutExtension>()));
  });

  test("Should not add Shortcut extension if platform is not Android",
      () async {
    final persistence = FakeLighthouseV2Bloc();
    persistence.shortcutsEnabled = true;
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    expect(device.deviceExtensions, isNot(contains(isA<ShortcutExtension>())));
  });

  test("Should add correct extensions, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    persistence.shortcutsEnabled = true;
    final device = LighthouseV2Device(
        FakeLighthouseV2Device(0, 0), persistence, (mac, name) {});

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(isA<ShortcutExtension>()));
    expect(device.deviceExtensions, contains(isA<StandbyExtension>()));
    expect(device.deviceExtensions, contains(isA<SleepExtension>()));
    expect(device.deviceExtensions, contains(isA<OnExtension>()));
  });

  test("Should get device name via shortcut extension", () async {
    final persistence = FakeLighthouseV2Bloc();
    persistence.shortcutsEnabled = true;

    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence,
        (mac, name) {
      expect(mac, "00:00:00:00:00:00");
      expect(name, "LHB-00000000");
    });

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    expect(device.deviceExtensions, contains(isA<ShortcutExtension>()));
    final extension = device.deviceExtensions
        .firstWhere((element) => element is ShortcutExtension);
    expect(extension, isNotNull);
    expect(extension, isA<ShortcutExtension>());

    await (extension as ShortcutExtension).onTap();
  });

  test("Should get nickname via shortcut extension", () async {
    final persistence = FakeLighthouseV2Bloc();
    persistence.shortcutsEnabled = true;

    final device = LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence,
        (mac, name) {
      expect(mac, "00:00:00:00:00:00");
      expect(name, "WOW!");
    });

    final valid = await device.isValid();
    expect(valid, true);
    device.afterIsValid();

    await Future.delayed(Duration(milliseconds: 10));

    device.nickname = "WOW!";

    expect(device.deviceExtensions, contains(isA<ShortcutExtension>()));
    final extension = device.deviceExtensions
        .firstWhere((element) => element is ShortcutExtension);
    expect(extension, isNotNull);
    expect(extension, isA<ShortcutExtension>());

    await (extension as ShortcutExtension).onTap();
  });

  test("Should return the correct device state", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    final lut = {
      0x00: LighthousePowerState.sleep,
      0x01: LighthousePowerState.booting,
      0x02: LighthousePowerState.standby,
      0x08: LighthousePowerState.booting,
      0x09: LighthousePowerState.booting,
      0x0b: LighthousePowerState.on,
    };

    for (int i = -0xFF; i < 0xFFE; i++) {
      final expectedState = lut[i] ?? LighthousePowerState.unknown;
      expect(device.powerStateFromByte(i), expectedState,
          reason:
              "State 0x${i.toRadixString(17).padLeft(2, '0')} should convert to $expectedState");
    }
  });

  test("Should call disconnect if connection becomes lost", () async {
    final persistence = FakeLighthouseV2Bloc();
    final lowLevel = OfflineAbleLighthouseDevice(0, 0);
    final device = LighthouseV2Device(lowLevel, persistence);

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
  });

  test("Should not get state if characteristic is not set", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    final state = await device.getCurrentState();
    expect(state, isNull,
        reason: "Should not get state if characteristic is null");
  });

  test("Should be able to go from sleep to on, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.unknown, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.sleep);

    // Now turn it on
    await device.changeState(LighthousePowerState.on);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.on, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should be able to go from sleep to standby, LighthouseV2Device",
      () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    var currentState = LighthousePowerState.unknown;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.unknown, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.sleep);

    // Now go to standby
    await device.changeState(LighthousePowerState.standby);

    var first = LighthousePowerState.unknown;
    var second = LighthousePowerState.unknown;
    var third = LighthousePowerState.unknown;
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

    expect(first, LighthousePowerState.standby,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.standby,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test('Should be able to go from on to sleep, LighthouseV2Device', () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.unknown, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.sleep);

    // Now turn it on
    await device.changeState(LighthousePowerState.on);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.on, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now go to sleep
    await device.changeState(LighthousePowerState.sleep);

    expect(await getNextPowerState(device, second, Duration(seconds: 1)),
        LighthousePowerState.sleep,
        reason: "Should directly switch to sleep");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test('Should be able to go from standby to sleep, LighthouseV2Device',
      () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    var currentState = LighthousePowerState.unknown;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.unknown, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.sleep);

    // Now go to standby
    await device.changeState(LighthousePowerState.standby);

    var first = LighthousePowerState.unknown;
    var second = LighthousePowerState.unknown;
    var third = LighthousePowerState.unknown;
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

    expect(first, LighthousePowerState.standby,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.standby,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now go to sleep
    await device.changeState(LighthousePowerState.sleep);

    var last = LighthousePowerState.unknown;
    try {
      last = await getNextPowerState(device, third, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(last, LighthousePowerState.sleep,
        reason: "Should directly switch to sleep");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should be able to go form standby to on, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 5);
    device.setUpdateInterval(Duration(milliseconds: 5));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    var currentState = LighthousePowerState.unknown;
    try {
      currentState = await getNextPowerState(
          device, LighthousePowerState.unknown, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(currentState, LighthousePowerState.sleep);

    // Now go to standby
    await device.changeState(LighthousePowerState.standby);

    var first = LighthousePowerState.unknown;
    var second = LighthousePowerState.unknown;
    var third = LighthousePowerState.unknown;
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

    expect(first, LighthousePowerState.standby,
        reason: "Should first switch to standby command");
    expect(second, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(third, LighthousePowerState.standby,
        reason: "Should then switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now turn it on
    await device.changeState(LighthousePowerState.on);

    var last = LighthousePowerState.unknown;
    try {
      last = await getNextPowerState(device, third, Duration(seconds: 1));
    } catch (e, s) {
      fail("$e, $s");
    }
    expect(last, LighthousePowerState.on,
        reason: "Should directly switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should be able to go from on to standby, LighthouseV2Device", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.unknown, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.sleep);

    // Now turn it on
    await device.changeState(LighthousePowerState.on);

    final first =
        await getNextPowerState(device, currentState, Duration(seconds: 2));
    final second = await getNextPowerState(device, first, Duration(seconds: 3));

    expect(first, LighthousePowerState.booting,
        reason: "Should first switch to booting");
    expect(second, LighthousePowerState.on, reason: "Should then switch to on");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");

    // Now turn it to standby
    await device.changeState(LighthousePowerState.standby);

    expect(await getNextPowerState(device, second, Duration(seconds: 1)),
        LighthousePowerState.standby,
        reason: "Should directly switch to standby");
    expect(device.transactionMutex.isLocked, false,
        reason: "Transaction mutex should have been released");
  });

  test("Should not go to unknown or booting power state", () async {
    final persistence = FakeLighthouseV2Bloc();
    final device =
        LighthouseV2Device(FakeLighthouseV2Device(0, 0), persistence);

    device.testingOverwriteMinUpdateInterval = Duration(milliseconds: 10);
    device.setUpdateInterval(Duration(milliseconds: 10));

    final valid = await device.isValid();
    expect(valid, true);

    //First turn off the device
    await device.changeState(LighthousePowerState.sleep);
    final currentState = await getNextPowerState(
        device, LighthousePowerState.unknown, Duration(seconds: 1));
    expect(currentState, LighthousePowerState.sleep);

    // Now try setting it to unknown
    await device.internalChangeState(LighthousePowerState.unknown);

    try {
      await getNextPowerState(device, currentState, Duration(seconds: 3));
      fail("Should not be able to get next state!");
    } on TimeoutException {
      expect(true, isTrue, reason: "Should not be able to get the next state");
      expect(device.transactionMutex.isLocked, false,
          reason: "Transaction mutex should have been released");
    }

    // Now turn setting it to booting
    await device.internalChangeState(LighthousePowerState.booting);

    try {
      await getNextPowerState(device, currentState, Duration(seconds: 3));
      fail("Should not be able to get next state!");
    } on TimeoutException {
      expect(true, isTrue, reason: "Should not be able to get the next state");
      expect(device.transactionMutex.isLocked, false,
          reason: "Transaction mutex should have been released");
    }
  });
}

Future<LighthousePowerState> getNextPowerState(LighthouseDevice device,
    LighthousePowerState previous, Duration timeout) async {
  return device.powerStateEnum
      .firstWhere((element) => element != previous)
      .timeout(timeout);
}
