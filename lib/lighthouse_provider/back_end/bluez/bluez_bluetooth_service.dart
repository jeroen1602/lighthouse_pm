import 'dart:typed_data';

import 'package:bluez/bluez.dart';

import '../../ble/bluetooth_characteristic.dart';
import '../../ble/bluetooth_service.dart';
import '../../ble/guid.dart';
import 'bluez_bluetooth_characteristic.dart';

class BlueZBluetoothService extends LHBluetoothService {
  BlueZBluetoothService(this.service);

  final BlueZGattService service;

  @override
  List<LHBluetoothCharacteristic> get characteristics => service.characteristics
      .map((e) => BlueZBluetoothCharacteristic(e))
      .toList();

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromBytes(
      ByteData.sublistView(Int8List.fromList(service.uuid.value)));
}
