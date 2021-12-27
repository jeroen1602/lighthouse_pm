library lighthouse_v2_device_provider;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/platform_specific/shared/local_platform.dart';
import 'package:rxdart/rxdart.dart';

part 'lighthouse_v2/device/lighthouse_v2_device.dart';

part 'lighthouse_v2/lighthouse_v2_persistence.dart';

part 'lighthouse_v2/specific_extensions/identify_device_extension.dart';

part 'lighthouse_v2/specific_extensions/standby_extension.dart';

///
/// A device provider for discovering and connection to [LighthouseV2Device]s.
///
class LighthouseV2DeviceProvider
    extends BLEDeviceProvider<LighthouseV2Persistence> {
  LighthouseV2DeviceProvider._();

  static LighthouseV2DeviceProvider? _instance;

  ///
  /// Get the instance of this [DeviceProvider].
  ///
  static LighthouseV2DeviceProvider get instance {
    return _instance ??= LighthouseV2DeviceProvider._();
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return LighthouseV2Device(device, requirePersistence());
  }

  @override
  List<LighthouseGuid> get characteristics => [
        LighthouseGuid.fromString(LighthouseV2Device.powerCharacteristicUUID),
        LighthouseGuid.fromString(LighthouseV2Device.channelCharacteristicUUID),
        LighthouseGuid.fromString(
            LighthouseV2Device.identifyCharacteristicUUID),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.MANUFACTURER_NAME_STRING.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.MODEL_NUMBER_STRING.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.SERIAL_NUMBER_STRING.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.HARDWARE_REVISION_STRING.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.FIRMWARE_REVISION_STRING.uuid),
      ];

  @override
  List<LighthouseGuid> get optionalServices => [
        LighthouseGuid.fromString(
            BluetoothDefaultServiceUUIDS.DEVICE_INFORMATION.uuid),
      ];

  @override
  List<LighthouseGuid> get requiredServices => [
        LighthouseGuid.fromString(LighthouseV2Device.controlServiceUUID),
      ];

  @override
  String get namePrefix => "LHB-";
}
