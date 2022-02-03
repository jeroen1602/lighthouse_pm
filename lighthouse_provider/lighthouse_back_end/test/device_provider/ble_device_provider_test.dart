import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should handle an error', () async {
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
  });

  test('Should clear open connections', () async {
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
  });
}
