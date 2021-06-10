import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/BLEDeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

import '../../helpers/FailingBLEDevice.dart';

class FakeHighLevelDevice extends BLEDevice {
  FakeHighLevelDevice(LHBluetoothDevice device) : super(device);

  @override
  void afterIsValid() {}

  @override
  Future cleanupConnection() async {}

  @override
  String get firmwareVersion => throw UnimplementedError();

  @override
  Future<int?> getCurrentState() {
    throw UnimplementedError();
  }

  @override
  bool get hasOpenConnection => throw UnimplementedError();

  @override
  Future internalChangeState(LighthousePowerState newState) {
    throw UnimplementedError();
  }

  @override
  String get name => device.name;

  @override
  Map<String, String?> get otherMetadata => throw UnimplementedError();

  @override
  LighthousePowerState powerStateFromByte(int byte) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isValid() async {
    try {
      await device.connect(timeout: Duration(milliseconds: 10));
    } on TimeoutException {
      return false;
    }

    final services = await device.discoverServices();
    return services.length > 0;
  }
}

class FakeBLEDeviceProvider extends BLEDeviceProvider {
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return FakeHighLevelDevice(device);
  }

  @override
  String get namePrefix => "LHB-";

  /// Not needed
  @override
  List<LighthouseGuid> get characteristics => throw UnimplementedError();

  /// Not needed
  @override
  List<LighthouseGuid> get optionalServices => throw UnimplementedError();

  /// Not needed
  @override
  List<LighthouseGuid> get requiredServices => throw UnimplementedError();
}

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

    final failingDevice = await instance.internalGetDevice(FailingBLEDeviceOnConnect());
    final failingDevice2 = await instance.internalGetDevice(FailingBLEDeviceOnConnect());

    instance.bleDevicesDiscovering.addAll([failingDevice, failingDevice2]);

    await instance.disconnectRunningDiscoveries();

    expect((failingDevice.device as FailingBLEDeviceOnConnect).disconnectCalls, 1, reason: "Disconnect should have been called");
    expect((failingDevice2.device as FailingBLEDeviceOnConnect).disconnectCalls, 1, reason: "Disconnect should have been called");
    expect(instance.bleDevicesDiscovering, isEmpty);

    LocalPlatform.overridePlatform = null;
  });
}
