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

  static ViveBaseStationDeviceProvider _instance;

  ///
  /// Get the instance of this [DeviceProvider].
  ///
  static ViveBaseStationDeviceProvider get instance {
    if (_instance == null) {
      _instance = ViveBaseStationDeviceProvider._();
    }
    return _instance;
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return ViveBaseStationDevice(device);
  }

  ///
  /// Check if the name of the device start correctly.
  ///
  @override
  bool nameCheck(String name) => name.startsWith('HTC BS');
}
