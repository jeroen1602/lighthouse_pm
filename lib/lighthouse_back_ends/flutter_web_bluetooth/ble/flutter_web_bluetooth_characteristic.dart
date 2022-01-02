part of flutter_web_bluetooth_back_end;

class FlutterWebBluetoothCharacteristic extends LHBluetoothCharacteristic {
  FlutterWebBluetoothCharacteristic(this.characteristic);

  final BluetoothCharacteristic characteristic;

  @override
  Future<List<int>> read() async {
    final value =
        await characteristic.readValue(timeout: Duration(seconds: 10));
    return value.toUint8List();
  }

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromString(characteristic.uuid);

  @override
  Future<void> write(List<int> data, {bool withoutResponse = false}) async {
    final payload = Uint8List.fromList(data);
    if (withoutResponse) {
      return characteristic.writeValueWithoutResponse(payload);
    } else {
      return characteristic.writeValueWithResponse(payload);
    }
  }
}
