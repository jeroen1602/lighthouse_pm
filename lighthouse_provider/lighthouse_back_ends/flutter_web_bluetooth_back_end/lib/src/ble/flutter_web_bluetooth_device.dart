part of flutter_web_bluetooth_back_end;

class FlutterWebBluetoothDevice extends LHBluetoothDevice {
  FlutterWebBluetoothDevice(this.device, this.characteristicsGuid);

  final BluetoothDevice device;
  final List<LighthouseGuid> characteristicsGuid;

  @override
  Future<void> connect({final Duration? timeout}) async {
    await device.connect(timeout: timeout);
  }

  @override
  Future<void> disconnect() async {
    return device.disconnect();
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    final discoveredServices = await device.discoverServices();
    final List<LHBluetoothService> services = [];
    for (final discoveredService in discoveredServices) {
      final service = await FlutterWebBluetoothService.withCharacteristics(
          discoveredService, characteristicsGuid);
      services.add(service);
    }
    return services;
  }

  @override
  LHDeviceIdentifier get id => LHDeviceIdentifier(device.id);

  @override
  String get name => device.name ?? '';

  @override
  Stream<LHBluetoothDeviceState> get state =>
      device.connected.map((final connected) => connected
          ? LHBluetoothDeviceState.connected
          : LHBluetoothDeviceState.disconnected);
}
