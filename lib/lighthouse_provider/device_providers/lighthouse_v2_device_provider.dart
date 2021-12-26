import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

import '../ble/bluetooth_device.dart';
import '../ble/guid.dart';
import '../devices/ble_device.dart';
import '../devices/lighthouse_v2_device.dart';
import 'ble_device_provider.dart';

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
    return _instance ??= LighthouseV2DeviceProvider._();
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
