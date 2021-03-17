import 'package:flutter_blue/flutter_blue.dart';

import '../../ble/BluetoothCharacteristic.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/Guid.dart';
import '../../helpers/FlutterBlueExtensions.dart';
import 'FlutterBlueBluetoothCharacteristic.dart';

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
