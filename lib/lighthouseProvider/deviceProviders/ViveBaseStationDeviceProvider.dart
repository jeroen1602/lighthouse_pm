import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';

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

  ViveBaseStationBloc? _bloc;

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
  /// Set the databased bloc for saving the ids of vive base stations.
  ///
  void setViveBaseStationBloc(ViveBaseStationBloc bloc) {
    this._bloc = bloc;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    if (this._bloc == null && !kReleaseMode) {
      throw StateError('Bloc is null, how?');
    }
    return ViveBaseStationDevice(device, _bloc!);
  }

  ///
  /// Check if the name of the device start correctly.
  ///
  @override
  bool nameCheck(String name) => name.startsWith('HTC BS');
}
