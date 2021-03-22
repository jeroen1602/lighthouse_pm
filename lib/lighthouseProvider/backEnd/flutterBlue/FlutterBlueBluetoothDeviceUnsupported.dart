import '../../ble/BluetoothDevice.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/DeviceIdentifier.dart';

/// An abstraction for the [FlutterBlue] [BluetoothDevice].
class FlutterBlueBluetoothDevice extends LHBluetoothDevice {
  FlutterBlueBluetoothDevice(dynamic ignored) {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  Future<void> connect({Duration? timeout}) {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  Future<void> disconnect() {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }

  @override
  LHDeviceIdentifier get id =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  String get name =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  Stream<LHBluetoothDeviceState> get state =>
      throw UnsupportedError("Flutter blue not supported for this platform");
}
