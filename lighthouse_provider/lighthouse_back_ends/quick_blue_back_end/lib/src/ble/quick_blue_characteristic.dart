part of quick_blue_back_end;

class QuickBlueCharacteristic extends LHBluetoothCharacteristic {
  QuickBlueCharacteristic(
    final String deviceId,
    final String serviceId,
    final String characteristicId,
    final ValueHandler valueHandler,
  )   : _deviceId = deviceId,
        _serviceId = serviceId,
        _characteristicId = characteristicId,
        _valueHandler = valueHandler,
        uuid = LighthouseGuid.fromString(characteristicId);

  final String _deviceId;
  final String _serviceId;
  final String _characteristicId;
  final ValueHandler _valueHandler;

  @override
  final LighthouseGuid uuid;

  @override
  Future<List<int>> read() {
    return _valueHandler.readValue(_deviceId, _serviceId, _characteristicId);
  }

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) {
    return _valueHandler.writeValue(_deviceId, _serviceId, _characteristicId,
        Uint8List.fromList(data), withoutResponse);
  }
}
