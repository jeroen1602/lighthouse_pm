import 'package:flutter_blue/flutter_blue.dart';

import '../../ble/BluetoothCharacteristic.dart';
import '../../ble/Guid.dart';
import '../../helpers/FlutterBlueExtensions.dart';

/// An abstraction for the [FlutterBlue]  [BluetoothCharacteristic].
class FlutterBlueBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterBlueBluetoothCharacteristic(this.characteristic);

  final BluetoothCharacteristic characteristic;

  @override
  Future<List<int>> read() => characteristic.read();

  @override
  LighthouseGuid get uuid => characteristic.uuid.toLighthouseGuid();

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) =>
      characteristic.write(data, withoutResponse: withoutResponse);
}
