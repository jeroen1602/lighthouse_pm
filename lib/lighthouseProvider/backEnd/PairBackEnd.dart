import 'package:lighthouse_pm/lighthouseProvider/backEnd/LighthouseBackEnd.dart';

///
/// A back end that requires the user to pair a device before it's able to be
/// used.
///
/// If there is a back end with this then there should be a pair button visible.
abstract class PairBackEnd {
  Future<void> pairNewDevice({required Duration timeout, required Duration? updateInterval});

  Stream<int> numberOfPairedDevices();

  Stream<bool> hasPairedDevices() {
    return numberOfPairedDevices().map((event) => event > 0);
  }
}

extension PairBackEndExtensions on LighthouseBackEnd {
  bool get isPairBackEnd {
    return this is PairBackEnd;
  }
}
