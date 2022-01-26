import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';

import '../../helpers/failing_ble_device.dart';
import '../../helpers/fake_ble_device_provider.dart';

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
