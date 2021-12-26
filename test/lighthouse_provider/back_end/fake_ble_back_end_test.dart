import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';

import '../../helpers/fake_bloc.dart';

void main() {
  test('Should assert updateLastSeen', () async {
    expect(() async {
      await FakeBLEBackEnd.instance.startScan(
          timeout: Duration(seconds: 1), updateInterval: Duration(seconds: 1));
    }, throwsA(TypeMatcher<AssertionError>()),
        reason: "updateLastSeen has not been set so it should throw an error.");
  });

  test('Should throw state error if no providers are set', () async {
    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    expect(() async {
      await FakeBLEBackEnd.instance.startScan(
          timeout: Duration(seconds: 1), updateInterval: Duration(seconds: 1));
    }, throwsA(TypeMatcher<StateError>()),
        reason:
            "Should throw a StateError if no device providers have been set.");
  });

  test('Should always report on state', () async {
    expect(await FakeBLEBackEnd.instance.state.first, BluetoothAdapterState.on);
  });

  test('Should get Lighthouse device V2', () async {
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fakeBloc = FakeBloc.normal();

    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    final provider = LighthouseV2DeviceProvider.instance;
    expect(backEnd.isMyProviderType(provider), true,
        reason: 'Back end should support the provider');
    provider.setBloc(fakeBloc);
    backEnd.addProvider(provider);

    backEnd.startScan(
        timeout: Duration(seconds: 1), updateInterval: Duration(seconds: 1));

    final firstDevice = await backEnd.lighthouseStream
        .firstWhere((element) => element != null)
        .timeout(Duration(seconds: 2));
    final secondDevice = await backEnd.lighthouseStream
        .firstWhere((element) =>
            element != null &&
            element.deviceIdentifier != firstDevice?.deviceIdentifier)
        .timeout(Duration(seconds: 2));

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
    LocalPlatform.overridePlatform = PlatformOverride.android;

    final fakeBloc = FakeBloc.normal();

    final backEnd = FakeBLEBackEnd.instance;
    backEnd.updateLastSeen = (LHDeviceIdentifier deviceIdentifier) {
      return true;
    };

    final provider = ViveBaseStationDeviceProvider.instance;
    expect(backEnd.isMyProviderType(provider), true,
        reason: 'Back end should support the provider');
    provider.setBloc(fakeBloc);
    backEnd.addProvider(provider);

    backEnd.startScan(
        timeout: Duration(seconds: 1), updateInterval: Duration(seconds: 1));

    final firstDevice = await backEnd.lighthouseStream
        .firstWhere((element) => element != null)
        .timeout(Duration(seconds: 2));
    final secondDevice = await backEnd.lighthouseStream
        .firstWhere((element) =>
            element != null &&
            element.deviceIdentifier != firstDevice?.deviceIdentifier)
        .timeout(Duration(seconds: 2));

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
