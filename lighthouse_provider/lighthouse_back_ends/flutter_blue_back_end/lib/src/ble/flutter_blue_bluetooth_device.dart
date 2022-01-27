part of flutter_blue_back_end;

/// An abstraction for the [FlutterBlue] [BluetoothDevice].
class FlutterBlueBluetoothDevice extends LHBluetoothDevice {
  FlutterBlueBluetoothDevice(this.device);

  final BluetoothDevice device;

  @override
  Future<void> connect({Duration? timeout}) {
    return device.connect(timeout: timeout);
  }

  @override
  Future<void> disconnect() {
    return device.disconnect();
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() {
    return device.discoverServices().then((services) =>
        services.map((e) => FlutterBlueBluetoothService(e)).toList());
  }

  @override
  Stream<LHBluetoothDeviceState> get state =>
      device.state.map((state) => state.toLHState());

  @override
  LHDeviceIdentifier get id => device.id.toLHDeviceIdentifier();

  @override
  String get name => device.name;
}
