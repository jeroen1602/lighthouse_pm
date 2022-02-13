import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_test_helper/lighthouse_test_helper.dart';
import 'package:shared_platform/shared_platform_io.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    SharedPlatform.overridePlatform = null;
  });

  test('Should assert updateLastSeen', () async {
    expect(() async {
      await FakeBLEBackEnd.instance.startScan(
          timeout: const Duration(seconds: 1),
          updateInterval: const Duration(seconds: 1));
    }, throwsA(isA<AssertionError>()),
        reason: "updateLastSeen has not been set so it should throw an error.");
  });

  test('Should throw state error if no providers are set', () async {
    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (final LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    expect(() async {
      await FakeBLEBackEnd.instance.startScan(
          timeout: const Duration(seconds: 1),
          updateInterval: const Duration(seconds: 1));
    }, throwsA(isA<StateError>()),
        reason:
            "Should throw a StateError if no device providers have been set.");
  });

  test('Should always report on state', () async {
    expect(await FakeBLEBackEnd.instance.state.first, BluetoothAdapterState.on);
  });

  test('Should get Lighthouse device V2', () async {
    SharedPlatform.overridePlatform = PlatformOverride.android;

    final persistence = FakeLighthouseV2Bloc();

    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (final LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    final provider = LighthouseV2DeviceProvider.instance;
    expect(backEnd.isMyProviderType(provider), true,
        reason: 'Back end should support the provider');
    provider.setPersistence(persistence);
    backEnd.addProvider(provider);

    backEnd.startScan(
        timeout: const Duration(seconds: 1),
        updateInterval: const Duration(seconds: 1));

    final firstDevice = await backEnd.lighthouseStream
        .firstWhere((final element) => element != null)
        .timeout(const Duration(seconds: 2));
    final secondDevice = await backEnd.lighthouseStream
        .firstWhere((final element) =>
            element != null &&
            element.deviceIdentifier != firstDevice?.deviceIdentifier)
        .timeout(const Duration(seconds: 2));

    expect(firstDevice, isNot(null));
    expect(secondDevice, isNot(null));

    expect(firstDevice!.deviceIdentifier.toString(), "00:00:00:00:00:00");
    expect(secondDevice!.deviceIdentifier.toString(), "00:00:00:00:00:01");

    expect(firstDevice.name, "LHB-00000000");
    expect(secondDevice.name, "LHB-00000001");

    // Cleanup
    await backEnd.disconnectOpenDevices();
    await backEnd.stopScan();
    await backEnd.cleanUp();
    expect(await backEnd.lighthouseStream.first, null);
    backEnd.removeProvider(provider);
  });

  test('Should get Lighthouse device Vive', () async {
    SharedPlatform.overridePlatform = PlatformOverride.android;

    final persistence = FakeViveBaseStationBloc();

    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (final LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    final provider = ViveBaseStationDeviceProvider.instance;
    expect(backEnd.isMyProviderType(provider), true,
        reason: 'Back end should support the provider');
    provider.setPersistence(persistence);
    backEnd.addProvider(provider);

    backEnd.startScan(
        timeout: const Duration(seconds: 1),
        updateInterval: const Duration(seconds: 1));

    final firstDevice = await backEnd.lighthouseStream
        .firstWhere((final element) => element != null)
        .timeout(const Duration(seconds: 2));
    final secondDevice = await backEnd.lighthouseStream
        .firstWhere((final element) =>
            element != null &&
            element.deviceIdentifier != firstDevice?.deviceIdentifier)
        .timeout(const Duration(seconds: 2));

    expect(firstDevice, isNot(null));
    expect(secondDevice, isNot(null));

    expect(firstDevice!.deviceIdentifier.toString(), "00:00:00:00:00:02");
    expect(secondDevice!.deviceIdentifier.toString(), "00:00:00:00:00:03");

    expect(firstDevice.name, "HTC BS 000000");
    expect(secondDevice.name, "HTC BS 000001");

    // Cleanup
    await backEnd.disconnectOpenDevices();
    await backEnd.stopScan();
    await backEnd.cleanUp();
    expect(await backEnd.lighthouseStream.first, null);
    backEnd.removeProvider(provider);
  });
}
