import 'dart:typed_data';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

import '../../ble/bluetooth_characteristic.dart';
import '../../ble/guid.dart';
import '../../helpers/byte_data_extensions.dart';

class FlutterWebBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterWebBluetoothCharacteristic(this.characteristic);

  final BluetoothCharacteristic characteristic;

  @override
  Future<List<int>> read() {
    return characteristic
        .readValue(timeout: Duration(seconds: 10))
        .then((value) {
      return value.toUint8List();
    });
  }

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromString(characteristic.uuid);

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) async {
    final payload = Uint8List.fromList(data);
    if (withoutResponse) {
      return characteristic.writeValueWithoutResponse(payload);
    } else {
      return characteristic.writeValueWithResponse(payload);
    }
  }
}
