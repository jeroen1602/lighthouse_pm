import '../backend/LowLevelDevice.dart';
import 'BluetoothService.dart';
import 'DeviceIdentifier.dart';

/// An abstract class for bluetooth devices.
///
/// Any bluetooth device should at least be able to do this.
abstract class LHBluetoothDevice implements LowLevelDevice {
  LHDeviceIdentifier get id;

  String get name;

  Stream<LHBluetoothDeviceState> get state;

  Future<void> connect({Duration timeout});

  Future<void> disconnect();

  Future<List<LHBluetoothService>> discoverServices();
}

/// The connection states that a device might have.
enum LHBluetoothDeviceState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  unknown
}
