part of flutter_blue_back_end;

/// An abstraction for the [FlutterBlue] [BluetoothService].
class FlutterBlueBluetoothService extends LHBluetoothService {
  FlutterBlueBluetoothService(this.service) {
    _characteristics.addAll(service.characteristics
        .map((final e) => FlutterBlueBluetoothCharacteristic(e)));
  }

  final BluetoothService service;
  final List<LHBluetoothCharacteristic> _characteristics = [];

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => service.uuid.toLighthouseGuid();
}
