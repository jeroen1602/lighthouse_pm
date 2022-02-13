import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should get only one instance', () {
    final instance = LighthouseV2DeviceProvider.instance;

    expect(instance, LighthouseV2DeviceProvider.instance);
  });

  test('Should throw an error if bloc is not set', () async {
    SharedPlatform.overridePlatform = PlatformOverride.android;
    final instance = LighthouseV2DeviceProvider.instance;

    // Make sure the bloc is null.
    instance.persistence = null;

    expect(() async {
      await instance.internalGetDevice(FakeLighthouseV2Device(0, 0));
    }, throwsA(isA<StateError>()));
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
