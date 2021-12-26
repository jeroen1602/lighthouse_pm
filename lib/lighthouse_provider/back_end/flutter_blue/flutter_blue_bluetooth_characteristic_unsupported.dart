import '../../ble/bluetooth_characteristic.dart';
import '../../ble/guid.dart';

/// An abstraction for the [FlutterBlue]  [BluetoothCharacteristic].
class FlutterBlueBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterBlueBluetoothCharacteristic(dynamic ignored) {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  Future<List<int>> read() {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  LighthouseGuid get uuid =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }
}
