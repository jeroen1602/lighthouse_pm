import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';

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

  ///
  /// Check if the name of the device start correctly.
  ///
  @override
  bool nameCheck(String name) => name.startsWith('HTC BS');
}
