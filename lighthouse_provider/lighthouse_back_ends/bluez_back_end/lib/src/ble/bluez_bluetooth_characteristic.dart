part of '../bluez_back_end_io.dart';

class BlueZBluetoothCharacteristic extends LHBluetoothCharacteristic {
  BlueZBluetoothCharacteristic(this.characteristic);

  final BlueZGattCharacteristic characteristic;

  @override
  Future<List<int>> read() {
    return characteristic.readValue();
  }

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromBytes(
      ByteData.sublistView(Int8List.fromList(characteristic.uuid.value)));

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    await characteristic.writeValue(data);
  }
}
