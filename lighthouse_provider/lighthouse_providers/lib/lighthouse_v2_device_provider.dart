library lighthouse_v2_device_provider;

import 'dart:async';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:shared_platform/shared_platform.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/device_extensions/shortcut_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';

part 'src/lighthouse_v2/device/lighthouse_v2_device.dart';

part 'src/lighthouse_v2/lighthouse_v2_persistence.dart';

part 'src/lighthouse_v2/specific_extensions/identify_device_extension.dart';

part 'src/lighthouse_v2/specific_extensions/standby_extension.dart';

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

  CreateShortcutCallback? _createShortcutCallback;

  void setCreateShortcutCallback(
      final CreateShortcutCallback? createShortcutCallback) {
    _createShortcutCallback = createShortcutCallback;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(final LHBluetoothDevice device) async {
    return LighthouseV2Device(
        device, requirePersistence(), _createShortcutCallback);
  }

  @override
  List<LighthouseGuid> get characteristics => [
        LighthouseGuid.fromString(LighthouseV2Device.powerCharacteristicUUID),
        LighthouseGuid.fromString(LighthouseV2Device.channelCharacteristicUUID),
        LighthouseGuid.fromString(
            LighthouseV2Device.identifyCharacteristicUUID),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.manufacturerNameString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.modelNumberString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.serialNumberString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.hardwareRevisionString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.firmwareRevisionString.uuid),
      ];

  @override
  List<LighthouseGuid> get optionalServices => [
        LighthouseGuid.fromString(
            BluetoothDefaultServiceUUIDS.deviceInformation.uuid),
      ];

  @override
  List<LighthouseGuid> get requiredServices => [
        LighthouseGuid.fromString(LighthouseV2Device.controlServiceUUID),
      ];

  @override
  String get namePrefix => "LHB-";

  @override
  String get providerName => "LighthouseV2DeviceProvider";
}
