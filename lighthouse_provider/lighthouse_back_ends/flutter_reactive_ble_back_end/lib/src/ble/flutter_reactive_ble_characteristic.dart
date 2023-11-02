part of '../flutter_reactive_ble_io.dart';

class FlutterReactiveBleCharacteristic extends LHBluetoothCharacteristic {
  FlutterReactiveBleCharacteristic(
    final String deviceId,
    final Characteristic characteristic,
  )   : _qualifiedCharacteristic = QualifiedCharacteristic(
            characteristicId: characteristic.id,
            serviceId: characteristic.service.id,
            deviceId: deviceId),
        uuid = LighthouseGuid.fromString(characteristic.id.toString());

  final QualifiedCharacteristic _qualifiedCharacteristic;
  final _flutterReactiveBle = FlutterReactiveBle();

  @override
  final LighthouseGuid uuid;

  @override
  Future<List<int>> read() {
    return _flutterReactiveBle.readCharacteristic(_qualifiedCharacteristic);
  }

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) {
    if (withoutResponse) {
      return _flutterReactiveBle.writeCharacteristicWithoutResponse(
          _qualifiedCharacteristic,
          value: data);
    } else {
      return _flutterReactiveBle.writeCharacteristicWithResponse(
          _qualifiedCharacteristic,
          value: data);
    }
  }
}
