part of "../flutter_blue_plus_back_end_io.dart";

/// An abstraction for the [blue_plus.FlutterBluePlus] [BluetoothDevice].
class FlutterBluePlusBluetoothDevice extends LHBluetoothDevice {
  FlutterBluePlusBluetoothDevice(this.device);

  final blue_plus.BluetoothDevice device;

  @override
  Future<void> connect({final Duration? timeout}) {
    return device.connect(timeout: timeout ?? const Duration(seconds: 35));
  }

  @override
  Future<void> disconnect() {
    return device.disconnect();
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() {
    return device.discoverServices().then((final services) =>
        services.map((final e) => FlutterBluePlusBluetoothService(e)).toList());
  }

  @override
  Stream<LHBluetoothDeviceState> get state =>
      device.connectionState.map((final state) => state.toLHState());

  @override
  LHDeviceIdentifier get id => device.remoteId.toLHDeviceIdentifier();

  @override
  String get name => device.platformName;
}
