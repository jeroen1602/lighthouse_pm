import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/bloc.dart';

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

  LighthousePMBloc? _bloc;

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
  /// Set the database bloc for saving the ids of vive base stations.
  ///
  void setLighthousePMBloc(LighthousePMBloc bloc) {
    this._bloc = bloc;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    if (this._bloc == null && !kReleaseMode) {
      throw StateError('Bloc is null');
    }
    return LighthouseV2Device(device, this._bloc!);
  }

  ///
  /// Check if the name of the device start correctly.
  ///
  @override
  bool nameCheck(String name) => name.startsWith('LHB-');
}
