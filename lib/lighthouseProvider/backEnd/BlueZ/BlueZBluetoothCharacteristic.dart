import 'dart:typed_data';

import 'package:bluez/bluez.dart';

import '../../ble/BluetoothCharacteristic.dart';
import '../../ble/Guid.dart';

class BlueZBluetoothCharacteristic extends LHBluetoothCharacteristic {
  BlueZBluetoothCharacteristic(this.characteristic);

  final BlueZGattCharacteristic characteristic;

  @override
  Future<List<int>> read() {
    return characteristic.readValue();
  }

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromBytes(
      ByteData.sublistView(Int8List.fromList(characteristic.uuid.value)));

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) async {
    await characteristic.writeValue(data);
  }
}
