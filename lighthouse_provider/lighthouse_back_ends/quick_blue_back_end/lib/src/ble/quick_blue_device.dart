part of quick_blue_back_end;

/// An abstraction for the [FlutterReactiveBle] bluetooth device.
class FlutterReactiveBleBluetoothDevice extends LHBluetoothDevice {
  FlutterReactiveBleBluetoothDevice(
      this.device,
      final ConnectionHandler connectionHandler,
      final ServiceHandler serviceHandler,
      final ValueHandler valueHandler)
      : id = LHDeviceIdentifier(device.deviceId),
        _connectionHandler = connectionHandler,
        _serviceHandler = serviceHandler,
        _valueHandler = valueHandler;

  final BlueScanResult device;
  final ConnectionHandler _connectionHandler;
  final ServiceHandler _serviceHandler;
  final ValueHandler _valueHandler;

  @override
  final LHDeviceIdentifier id;

  @override
  Future<void> connect({final Duration? timeout}) async {
    QuickBlue.connect(device.deviceId);
    if (timeout != null) {
      try {
        await _connectionHandler
            .waitForState(device.deviceId, BlueConnectionState.connected)
            .timeout(timeout);
      } on TimeoutException {
        await disconnect();
        rethrow;
      }
    } else {
      await _connectionHandler.waitForState(
          device.deviceId, BlueConnectionState.connected);
    }
  }

  @override
  Future<void> disconnect() async {
    QuickBlue.disconnect(device.deviceId);
    try {
      await _connectionHandler
          .waitForState(device.deviceId, BlueConnectionState.connected)
          .timeout(const Duration(seconds: 5));
    } on TimeoutException {
      lighthouseLogger.severe("Ignored error while tyring to disconnect $id");
      // ignore exception.
    } finally {
      _connectionHandler.removeSubject(device.deviceId);
      _serviceHandler.removeSubject(device.deviceId);
    }
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    QuickBlue.discoverServices(device.deviceId);

    return await _serviceHandler.waitForServices(device.deviceId).then((value) {
      return value.map((serviceAndCharacteristics) {
        return QuickBlueService(
            serviceAndCharacteristics.serviceId,
            serviceAndCharacteristics.characteristicIds
                .map((final characteristic) {
              return QuickBlueCharacteristic(
                  device.deviceId,
                  serviceAndCharacteristics.serviceId,
                  characteristic,
                  _valueHandler);
            }).toList());
      }).toList();
    });
  }

  @override
  Stream<LHBluetoothDeviceState> get state =>
      _connectionHandler.getOrCreateStream(device.deviceId).map((final state) {
        switch (state) {
          case BlueConnectionState.connected:
            return LHBluetoothDeviceState.connected;
          case BlueConnectionState.disconnected:
            return LHBluetoothDeviceState.disconnected;
          default:
            assert(false, "This shouldn't happen");
            lighthouseLogger.severe("Unhandled device state in the converter");
            return LHBluetoothDeviceState.unknown;
        }
      });

  @override
  String get name => device.name;
}
