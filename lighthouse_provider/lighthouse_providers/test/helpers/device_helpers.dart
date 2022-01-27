import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:shared_platform/shared_platform_io.dart';

import 'fake_bloc.dart';

Future<ViveBaseStationDevice> createValidViveDevice(
    int deviceName, int deviceId,
    [ViveBaseStationPersistence? persistence, RequestPairId? pairId]) async {
  SharedPlatform.overridePlatform = PlatformOverride.android;
  persistence ??= FakeViveBaseStationBloc();
  final device = ViveBaseStationDevice(
      FakeViveBaseStationDevice(deviceName, deviceId), persistence, pairId);

  SharedPlatform.overridePlatform = null;
  return await doTheIsValid(device);
}

Future<LighthouseV2Device> createValidLighthouseV2Device(
    int deviceName, int deviceId,
    [LighthouseV2Persistence? persistence]) async {
  SharedPlatform.overridePlatform = PlatformOverride.android;
  persistence ??= FakeLighthouseV2Bloc();
  final device = LighthouseV2Device(
      FakeLighthouseV2Device(deviceName, deviceId), persistence);

  SharedPlatform.overridePlatform = null;
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
