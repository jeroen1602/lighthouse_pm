import 'package:flutter/foundation.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';

import '../ble/BluetoothDevice.dart';
import '../devices/BLEDevice.dart';
import '../devices/LighthouseV2Device.dart';
import '../devices/ViveBaseStationDevice.dart';
import 'BLEDeviceProvider.dart';

///
/// A device provider for discovering and connection to [LighthouseV2Device]s.
///
class ViveBaseStationDeviceProvider extends BLEDeviceProvider {
  ViveBaseStationDeviceProvider._();

  ViveBaseStationDao? _viveDao;

  static ViveBaseStationDeviceProvider? _instance;

  ///
  /// Get the instance of this [DeviceProvider].
  ///
  static ViveBaseStationDeviceProvider get instance {
    if (_instance == null) {
      _instance = ViveBaseStationDeviceProvider._();
    }
    return _instance!;
  }

  ///
  /// Set the database dao for saving the ids of vive base stations.
  ///
  void setViveBaseStationDao(ViveBaseStationDao dao) {
    this._viveDao = dao;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    if (this._viveDao == null && !kReleaseMode) {
      throw StateError('Bloc is null, how?');
    }
    return ViveBaseStationDevice(device, _viveDao!);
  }

  @override
  List<LighthouseGuid> get characteristics => [
        LighthouseGuid.fromString(ViveBaseStationDevice.POWER_CHARACTERISTIC),
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
        LighthouseGuid.fromString(ViveBaseStationDevice.POWER_SERVICE),
      ];

  @override
  String get namePrefix => "HTC BS";
}
