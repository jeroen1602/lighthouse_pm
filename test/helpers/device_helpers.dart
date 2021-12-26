import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouse_provider/back_end/fake/fake_bluetooth_device.dart';
import 'package:lighthouse_pm/lighthouse_provider/devices/ble_device.dart';
import 'package:lighthouse_pm/lighthouse_provider/devices/lighthouse_v2_device.dart';
import 'package:lighthouse_pm/lighthouse_provider/devices/vive_base_station_device.dart';
import 'package:lighthouse_pm/platform_specific/mobile/local_platform.dart';

import 'fake_bloc.dart';

Future<ViveBaseStationDevice> createValidViveDevice(
    int deviceName, int deviceId,
    [LighthousePMBloc? bloc]) async {
  LocalPlatform.overridePlatform = PlatformOverride.android;
  bloc ??= FakeBloc.normal();
  final device = ViveBaseStationDevice(
      FakeViveBaseStationDevice(deviceName, deviceId), bloc);

  LocalPlatform.overridePlatform = null;
  return await doTheIsValid(device);
}

Future<LighthouseV2Device> createValidLighthouseV2Device(
    int deviceName, int deviceId,
    [LighthousePMBloc? bloc]) async {
  LocalPlatform.overridePlatform = PlatformOverride.android;
  bloc ??= FakeBloc.normal();
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
