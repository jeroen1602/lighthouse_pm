import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/LighthouseV2DeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/ViveBaseStationDeviceProvider.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

void main() {
  LocalPlatform.overridePlatform = PlatformOverride.android;

  test('Should create FakeBluetoothDevice', () async {
    final device = FakeBluetoothDevice([], 0, 'TEST-DEVICE');

    final services = await device.discoverServices();

    expect(device.name, 'TEST-DEVICE');
    expect(device.id.toString(), '00:00:00:00:00:00');
    expect(services.length, 1);
    expect(services[0].characteristics, []);
    expect(services[0].uuid.toString(), "00000000-0000-0000-0000-000000000001");
  });

  test('Should create FakeLighthouseV2Device', () async {
    final device = FakeLighthouseV2Device(0xFF, 0);

    final services = await device.discoverServices();

    expect(device.name, 'LHB-000000FF');
    expect(device.id.toString(), '00:00:00:00:00:00');
    expect(services.length, 1);
  });

  test('FakeLighthouseV2Device should contain characteristics', () async {
    final device = FakeLighthouseV2Device(0xFF, 0);

    final services = await device.discoverServices();

    expect(device.id.toString(), '00:00:00:00:00:00');
    expect(services.length, 1);
    final characteristics = services[0].characteristics;

    final provider = LighthouseV2DeviceProvider.instance;
    final expectedCharacteristics = provider.characteristics;

    expect(characteristics.length, expectedCharacteristics.length,
        reason:
            "should have the same amount of characteristics as the expected "
            "amount of characteristics.");

    for (final characteristic in expectedCharacteristics) {
      final index = characteristics
          .indexWhere((element) => element.uuid == characteristic);
      expect(index, isNot(-1),
          reason: 'Should have "${characteristic.toString()}" characteristic');
    }
  });

  test('Should create FakeViveBaseStationDevice', () async {
    final device = FakeViveBaseStationDevice(0xFF, 0);

    final services = await device.discoverServices();

    expect(device.name, 'HTC BS 0000FF');
    expect(device.id.toString(), '00:00:00:00:00:00');
    expect(services.length, 1);
  });

  test('FakeViveBaseStationDevice should contain characteristics', () async {
    final device = FakeViveBaseStationDevice(0xFF, 0);

    final services = await device.discoverServices();

    expect(device.id.toString(), '00:00:00:00:00:00');
    expect(services.length, 1);
    final characteristics = services[0].characteristics;

    final provider = ViveBaseStationDeviceProvider.instance;
    final expectedCharacteristics = provider.characteristics;

    expect(characteristics.length, expectedCharacteristics.length,
        reason:
            "should have the same amount of characteristics as the expected "
            "amount of characteristics.");

    for (final characteristic in expectedCharacteristics) {
      final index = characteristics
          .indexWhere((element) => element.uuid == characteristic);
      expect(index, isNot(-1),
          reason: 'Should have "${characteristic.toString()}" characteristic');
    }
  });
}
