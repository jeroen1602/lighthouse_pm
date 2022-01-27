part of flutter_blue_back_end;

/// An abstraction for the [FlutterBlue]  [BluetoothCharacteristic].
class FlutterBlueBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterBlueBluetoothCharacteristic(this.characteristic);

  final BluetoothCharacteristic characteristic;

  @override
  Future<List<int>> read() => characteristic.read();

  @override
  LighthouseGuid get uuid => characteristic.uuid.toLighthouseGuid();

  @override
  Future<void> write(final List<int> data,
          {final bool withoutResponse = false}) =>
      characteristic.write(data, withoutResponse: withoutResponse);
}
