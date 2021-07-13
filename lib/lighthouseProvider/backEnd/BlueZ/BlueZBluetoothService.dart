import 'dart:typed_data';

import 'package:bluez/bluez.dart';

import '../../ble/BluetoothCharacteristic.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/Guid.dart';
import 'BlueZBluetoothCharacteristic.dart';

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
