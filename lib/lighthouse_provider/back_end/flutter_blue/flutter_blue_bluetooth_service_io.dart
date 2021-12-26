import 'package:flutter_blue/flutter_blue.dart';

import '../../ble/bluetooth_characteristic.dart';
import '../../ble/bluetooth_service.dart';
import '../../ble/guid.dart';
import '../../helpers/flutter_blue_extensions.dart';
import 'flutter_blue_bluetooth_characteristic.dart';

/// An abstraction for the [FlutterBlue] [BluetoothService].
class FlutterBlueBluetoothService extends LHBluetoothService {
  FlutterBlueBluetoothService(this.service) {
    _characteristics.addAll(service.characteristics
        .map((e) => FlutterBlueBluetoothCharacteristic(e)));
  }

  final BluetoothService service;
  final List<LHBluetoothCharacteristic> _characteristics = [];

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => service.uuid.toLighthouseGuid();
}
