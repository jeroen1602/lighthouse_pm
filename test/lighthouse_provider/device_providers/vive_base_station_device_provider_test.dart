import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_provider/back_end/fake/fake_bluetooth_device.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';

void main() {
  test('Should get only one instance', () {
    final instance = ViveBaseStationDeviceProvider.instance;

    expect(instance, ViveBaseStationDeviceProvider.instance);
  });

  test('Should throw an error if bloc is not set', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = ViveBaseStationDeviceProvider.instance;

    // Make sure the bloc is null.
    instance.bloc = null;

    expect(() async {
      await instance.internalGetDevice(FakeViveBaseStationDevice(0, 0));
    }, throwsA(TypeMatcher<StateError>()));

    LocalPlatform.overridePlatform = null;
  });

  test('Should have the expected services and characteristics', () {
    final instance = ViveBaseStationDeviceProvider.instance;

    expect(instance.characteristics.length, 6,
        reason: "Should have expected characteristics");
    expect(instance.optionalServices.length, 1,
        reason: "Should have expected optional services");
    expect(instance.requiredServices.length, 1,
        reason: "Should have expected required services");
  });
}