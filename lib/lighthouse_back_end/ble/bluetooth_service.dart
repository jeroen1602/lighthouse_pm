part of lighthouse_back_end;

/// An abstract bluetooth service.
///
/// All bluetooth service should at least be able to do this.
abstract class LHBluetoothService {
  LighthouseGuid get uuid;

  List<LHBluetoothCharacteristic> get characteristics;
}
