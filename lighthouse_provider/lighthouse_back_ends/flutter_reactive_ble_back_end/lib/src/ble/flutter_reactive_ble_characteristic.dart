part of flutter_reactive_ble_back_end;

class FlutterReactiveBleCharacteristic extends LHBluetoothCharacteristic {
  FlutterReactiveBleCharacteristic(
    final String deviceId,
    final DiscoveredCharacteristic characteristic,
  )   : _qualifiedCharacteristic = QualifiedCharacteristic(
            characteristicId: characteristic.characteristicId,
            serviceId: characteristic.serviceId,
            deviceId: deviceId),
        uuid = LighthouseGuid.fromString(
            characteristic.characteristicId.toString());

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
