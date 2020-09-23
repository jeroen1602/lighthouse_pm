import 'BluetoothCharacteristic.dart';
import 'Guid.dart';

/// An abstract bluetooth service.
///
/// All bluetooth service should at least be able to do this.
abstract class LHBluetoothService {
  LighthouseGuid get uuid;

  List<LHBluetoothCharacteristic> get characteristics;
}
