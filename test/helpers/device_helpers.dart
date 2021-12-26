import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_back_ends/fake/fake_back_end.dart';
import 'package:lighthouse_pm/lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_providers/vive_base_station_device_provider.dart';
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
