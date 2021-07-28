import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/platformSpecific/io/LocalPlatform.dart';

void main() {
  test('Should get only one instance', () {
    final instance = LighthouseV2DeviceProvider.instance;

    expect(instance, LighthouseV2DeviceProvider.instance);
  });

  test('Should throw an error if bloc is not set', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;
    final instance = LighthouseV2DeviceProvider.instance;

    // Make sure the bloc is null.
    instance.bloc = null;

    expect(() async {
      await instance.internalGetDevice(FakeLighthouseV2Device(0, 0));
    }, throwsA(TypeMatcher<StateError>()));

    LocalPlatform.overridePlatform = null;
  });

  test('Should have the expected services and characteristics', () {
    final instance = LighthouseV2DeviceProvider.instance;

    expect(instance.characteristics.length, 8,
        reason: "Should have expected characteristics");
    expect(instance.optionalServices.length, 1,
        reason: "Should have expected optional services");
    expect(instance.requiredServices.length, 1,
        reason: "Should have expected required services");
  });
}
