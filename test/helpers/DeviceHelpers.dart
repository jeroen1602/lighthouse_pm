import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/LighthouseV2Device.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/ViveBaseStationDevice.dart';
import 'package:lighthouse_pm/platformSpecific/mobile/LocalPlatform.dart';

import 'FakeBloc.dart';

Future<ViveBaseStationDevice> createValidViveDevice(
    int deviceName, int deviceId) async {
  LocalPlatform.overridePlatform = PlatformOverride.android;
  final bloc = FakeBloc.normal();
  final device = ViveBaseStationDevice(
      FakeViveBaseStationDevice(deviceName, deviceId), bloc);

  LocalPlatform.overridePlatform = null;
  return await doTheIsValid(device);
}

Future<LighthouseV2Device> createValidLighthouseV2Device(
    int deviceName, int deviceId) async {
  LocalPlatform.overridePlatform = PlatformOverride.android;
  final bloc = FakeBloc.normal();
  final device =
      LighthouseV2Device(FakeLighthouseV2Device(deviceName, deviceId), bloc);

  LocalPlatform.overridePlatform = null;
  return await doTheIsValid(device);
}

Future<T> doTheIsValid<T extends BLEDevice>(T device) async {
  final valid = await device.isValid();
  if (!valid) {
    throw StateError("Should be valid!");
  }
  device.afterIsValid();

  return device;
}
