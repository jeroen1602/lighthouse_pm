import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

import '../../ble/bluetooth_characteristic.dart';
import '../../ble/bluetooth_service.dart';
import '../../ble/guid.dart';
import 'flutter_web_bluetooth_characteristic.dart';

class FlutterWebBluetoothService extends LHBluetoothService {
  FlutterWebBluetoothService(
      this.service, List<FlutterWebBluetoothCharacteristic> characteristics)
      : _characteristics = characteristics;

  static Future<FlutterWebBluetoothService> withCharacteristics(
      BluetoothService service,
      List<LighthouseGuid> characteristicsGuid) async {
    final List<FlutterWebBluetoothCharacteristic> characteristics = [];

    for (final characteristicGuid in characteristicsGuid) {
      try {
        final characteristic = await service
            .getCharacteristic(characteristicGuid.toString().toLowerCase());
        characteristics.add(FlutterWebBluetoothCharacteristic(characteristic));
      } catch (error) {
        if (error is NotFoundError) {
          print(
              "Characteristic ${characteristicGuid.toString()} not found in service ${service.uuid}, that's ok.");
        } else if (error is SecurityError) {
          print(
              "Security error for characteristic ${characteristicGuid.toString()} in service ${service.uuid}, that's ok.");
        } else {
          rethrow;
        }
      }
    }
    return FlutterWebBluetoothService(service, characteristics);
  }

  final BluetoothService service;
  final List<FlutterWebBluetoothCharacteristic> _characteristics;

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromString(service.uuid);
}