// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:meta/meta.dart';
import 'package:shared_platform/shared_platform_io.dart';

import 'fake_persistence.dart';

@visibleForTesting
Future<ViveBaseStationDevice> createValidViveDevice(
    final int deviceName, final int deviceId,
    [ViveBaseStationPersistence? persistence,
    final RequestPairId? pairId]) async {
  final startPlatform = SharedPlatform.overridePlatform;
  SharedPlatform.overridePlatform = PlatformOverride.android;
  persistence ??= FakeViveBaseStationBloc();
  final device = ViveBaseStationDevice(
      FakeViveBaseStationDevice(deviceName, deviceId), persistence, pairId);

  SharedPlatform.overridePlatform = startPlatform;
  return await doTheIsValid(device);
}

@visibleForTesting
Future<LighthouseV2Device> createValidLighthouseV2Device(
    final int deviceName, final int deviceId,
    [LighthouseV2Persistence? persistence]) async {
  final startPlatform = SharedPlatform.overridePlatform;
  SharedPlatform.overridePlatform = PlatformOverride.android;
  persistence ??= FakeLighthouseV2Bloc();
  final device = LighthouseV2Device(
      FakeLighthouseV2Device(deviceName, deviceId), persistence);

  SharedPlatform.overridePlatform = startPlatform;
  return await doTheIsValid(device);
}

@visibleForTesting
Future<T> doTheIsValid<T extends BLEDevice>(final T device) async {
  final valid = await device.isValid();
  if (!valid) {
    throw StateError("Should be valid!");
  }
  device.afterIsValid();

  return device;
}
