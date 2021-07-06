import 'package:flutter/foundation.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';

import '../ble/BluetoothDevice.dart';
import '../devices/BLEDevice.dart';
import '../devices/LighthouseV2Device.dart';
import 'BLEDeviceProvider.dart';

///
/// A device provider for discovering and connection to [LighthouseV2Device]s.
///
class LighthouseV2DeviceProvider extends BLEDeviceProvider {
  LighthouseV2DeviceProvider._();

  static LighthouseV2DeviceProvider? _instance;

  ///
  /// Get the instance of this [DeviceProvider].
  ///
  static LighthouseV2DeviceProvider get instance {
    if (_instance == null) {
      _instance = LighthouseV2DeviceProvider._();
    }
    return _instance!;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return LighthouseV2Device(device, requireBloc());
  }

  @override
  List<LighthouseGuid> get characteristics => [
        LighthouseGuid.fromString(LighthouseV2Device.POWER_CHARACTERISTIC),
        LighthouseGuid.fromString(LighthouseV2Device.CHANNEL_CHARACTERISTIC),
        LighthouseGuid.fromString(LighthouseV2Device.IDENTIFY_CHARACTERISTIC),
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
        LighthouseGuid.fromString(LighthouseV2Device.CONTROL_SERVICE),
      ];

  @override
  String get namePrefix => "LHB-";
}
