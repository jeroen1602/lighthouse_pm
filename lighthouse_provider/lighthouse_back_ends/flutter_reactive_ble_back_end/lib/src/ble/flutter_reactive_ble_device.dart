part of flutter_reactive_ble_back_end;

/// An abstraction for the [FlutterReactiveBle] bluetooth device.
class FlutterReactiveBleBluetoothDevice extends LHBluetoothDevice {
  FlutterReactiveBleBluetoothDevice(
    this.device,
  ) : id = LHDeviceIdentifier(device.id);

  final DiscoveredDevice device;
  final _flutterReactiveBle = FlutterReactiveBle();
  StreamSubscription? _connectionSubscription;
  final BehaviorSubject<ConnectionStateUpdate> _connectionSubject =
      BehaviorSubject();

  @override
  final LHDeviceIdentifier id;

  @override
  Future<void> connect({Duration? timeout}) async {
    final connection = _connectionSubscription;
    _connectionSubscription = null;
    await connection?.cancel();
    _connectionSubscription = _flutterReactiveBle
        .connectToAdvertisingDevice(
            id: device.id,
            withServices: [],
            prescanDuration: const Duration(seconds: 5),
            connectionTimeout: timeout)
        .listen((event) {
      _connectionSubject.add(event);
    });

    if (timeout == null) {
      return _connectionSubject.stream
          .firstWhere((element) =>
              element.connectionState == DeviceConnectionState.connected)
          .then((final _) {
        return;
      });
    } else {
      if (timeout < FlutterReactiveBleBackEnd._minimumConnectDuration) {
        timeout = FlutterReactiveBleBackEnd._minimumConnectDuration;
      }
      return _connectionSubject.stream
          .firstWhere((element) =>
              element.connectionState == DeviceConnectionState.connected)
          .timeout(timeout)
          .then((final _) {
        return;
      });
    }
  }

  @override
  Future<void> disconnect() async {
    final connection = _connectionSubscription;
    _connectionSubscription = null;
    if (connection != null) {
      await connection.cancel();
    }
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    final services = await _flutterReactiveBle.discoverServices(device.id);

    return services.map((final service) {
      return FlutterReactiveBleService(device.id, service);
    }).toList();
  }

  @override
  Stream<LHBluetoothDeviceState> get state =>
      _connectionSubject.stream.map((final update) {
        switch (update.connectionState) {
          case DeviceConnectionState.connecting:
            return LHBluetoothDeviceState.connecting;
          case DeviceConnectionState.connected:
            return LHBluetoothDeviceState.connected;
          case DeviceConnectionState.disconnecting:
            return LHBluetoothDeviceState.disconnecting;
          case DeviceConnectionState.disconnected:
            return LHBluetoothDeviceState.disconnected;
        }
      });

  @override
  String get name => device.name;
}
