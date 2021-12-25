import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/BLEDeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

import '../../helpers/FailingBLEDevice.dart';
import '../../helpers/FakeBLEDeviceProvider.dart';
import '../../helpers/FakeHighLevelDevice.dart';

void main() {
  test('Should handle an error', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final instance = FakeBLEDeviceProvider();

    final failingDevice = FailingBLEDeviceOnConnect();

    var value = await instance.getDevice(failingDevice,
        updateInterval: Duration(milliseconds: 10));

    expect(value, isNull);
    expect(failingDevice.disconnectCalls, 1,
        reason: "Disconnect should have been called");

    final failingDevice2 = FailingBLEDeviceOnDiscover();

    value = await instance.getDevice(failingDevice2,
        updateInterval: Duration(milliseconds: 10));

    expect(value, isNull);
    expect(failingDevice.disconnectCalls, 1,
        reason: "Disconnect should have been called");

    LocalPlatform.overridePlatform = null;
  });

  test('Should clear open connections', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final instance = FakeBLEDeviceProvider();

    final failingDevice =
        await instance.internalGetDevice(FailingBLEDeviceOnConnect());
    final failingDevice2 =
        await instance.internalGetDevice(FailingBLEDeviceOnDiscover());

    instance.bleDevicesDiscovering.addAll([failingDevice, failingDevice2]);

    await instance.disconnectRunningDiscoveries();

    expect(
        (failingDevice.device as FailingBLEDeviceOnConnect).disconnectCalls, 1,
        reason: "Disconnect should have been called");
    expect(
        (failingDevice2.device as FailingBLEDeviceOnDiscover).disconnectCalls,
        1,
        reason: "Disconnect should have been called");
    expect(instance.bleDevicesDiscovering, isEmpty);

    LocalPlatform.overridePlatform = null;
  });
}
