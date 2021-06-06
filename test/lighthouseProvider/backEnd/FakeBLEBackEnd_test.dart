import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/adapterState/AdapterState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/FakeBLEBackEnd.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

import '../../helpers/FakeBloc.dart';

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
    provider.setLighthousePMBloc(fakeBloc);
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
    provider.setViveBaseStationDao(fakeBloc.viveBaseStation);
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
