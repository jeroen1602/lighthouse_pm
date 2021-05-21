import '../../ble/BluetoothCharacteristic.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/Guid.dart';

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
