import '../../ble/bluetooth_characteristic.dart';
import '../../ble/bluetooth_service.dart';
import '../../ble/guid.dart';

class FlutterBlueBluetoothService extends LHBluetoothService {
  FlutterBlueBluetoothService(dynamic ignored) {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  List<LHBluetoothCharacteristic> get characteristics =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  LighthouseGuid get uuid =>
      throw UnsupportedError("Flutter blue not supported for this platform");
}
