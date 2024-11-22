part of "../flutter_blue_plus_back_end_io.dart";

/// An abstraction for the [blue_plus.FlutterBluePlus]  [BluetoothCharacteristic].
class FlutterBluePlusBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterBluePlusBluetoothCharacteristic(this.characteristic);

  final blue_plus.BluetoothCharacteristic characteristic;

  @override
  Future<List<int>> read() => characteristic.read();

  @override
  LighthouseGuid get uuid => characteristic.uuid.toLighthouseGuid();

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    if (characteristic.properties.writeWithoutResponse && withoutResponse) {
      await characteristic.write(data, withoutResponse: true);
    } else {
      await characteristic.write(data, withoutResponse: false);
    }
  }
}
