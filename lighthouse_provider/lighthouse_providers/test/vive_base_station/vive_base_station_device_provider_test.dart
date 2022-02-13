import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    SharedPlatform.overridePlatform = PlatformOverride.android;
  });

  tearDown(() {
    SharedPlatform.overridePlatform = null;

    final instance = ViveBaseStationDeviceProvider.instance;
    instance.requestCallback = null;
  });

  test('Should get only one instance', () {
    final instance = ViveBaseStationDeviceProvider.instance;

    expect(instance, ViveBaseStationDeviceProvider.instance);
  });

  test('Should throw an error if bloc is not set', () async {
    final instance = ViveBaseStationDeviceProvider.instance;

    // Make sure the bloc is null.
    instance.persistence = null;

    expect(() async {
      await instance.internalGetDevice(FakeViveBaseStationDevice(0, 0));
    }, throwsA(isA<StateError>()));
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

  test('Should set request pair id callback', () async {
    final instance = ViveBaseStationDeviceProvider.instance;

    bool called = false;
    method(final String? context, final int? pairIdHint) async {
      called = true;
      return context;
    }

    instance.setRequestPairIdCallback<String>(method);

    expect(instance.requestCallback, isNotNull);
    expect(await instance.requestCallback!.call("hello", null), "hello");
    expect(called, isTrue);
  });
}
