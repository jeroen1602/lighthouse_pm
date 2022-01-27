import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:test/test.dart';

void main() {
  test('Should convert to the correct string', () {
    final lut = {
      BluetoothAdapterState.unknown: "unknown",
      BluetoothAdapterState.unavailable: "unavailable",
      BluetoothAdapterState.unauthorized: "unauthorized",
      BluetoothAdapterState.turningOn: "turning on",
      BluetoothAdapterState.on: "on",
      BluetoothAdapterState.turningOff: "turning off",
      BluetoothAdapterState.off: "off",
      BluetoothAdapterState.error: "error",
    };

    for (final item in lut.entries) {
      expect(
          BluetoothAdapterStateFunctions.stateToString(item.key), item.value);
    }
  });
}
