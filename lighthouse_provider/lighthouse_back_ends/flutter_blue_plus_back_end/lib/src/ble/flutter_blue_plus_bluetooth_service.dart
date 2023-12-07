part of flutter_blue_plus_back_end;

/// An abstraction for the [blue_plus.FlutterBluePlus] [BluetoothService].
class FlutterBluePlusBluetoothService extends LHBluetoothService {
  FlutterBluePlusBluetoothService(this.service) {
    _characteristics.addAll(service.characteristics
        .map((final e) => FlutterBluePlusBluetoothCharacteristic(e)));
  }

  final blue_plus.BluetoothService service;
  final List<LHBluetoothCharacteristic> _characteristics = [];

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => service.uuid.toLighthouseGuid();
}
