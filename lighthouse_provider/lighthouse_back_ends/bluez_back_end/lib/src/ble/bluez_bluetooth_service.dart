part of bluez_back_end;

class BlueZBluetoothService extends LHBluetoothService {
  BlueZBluetoothService(this.service);

  final BlueZGattService service;

  @override
  List<LHBluetoothCharacteristic> get characteristics => service.characteristics
      .map((final e) => BlueZBluetoothCharacteristic(e))
      .toList();

  @override
  LighthouseGuid get uuid => LighthouseGuid.fromBytes(
      ByteData.sublistView(Int8List.fromList(service.uuid.value)));
}
