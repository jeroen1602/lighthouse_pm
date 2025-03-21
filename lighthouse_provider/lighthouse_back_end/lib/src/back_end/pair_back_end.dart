part of '../../lighthouse_back_end.dart';

///
/// A back end that requires the user to pair a device before it's able to be
/// used.
///
/// If there is a back end with this then there should be a pair button visible.
abstract mixin class PairBackEnd {
  Future<void> pairNewDevice(
      {required final Duration timeout,
      required final Duration? updateInterval});

  Stream<int> numberOfPairedDevices();

  Stream<bool> hasPairedDevices() {
    return numberOfPairedDevices().map((final event) => event > 0);
  }
}

extension PairBackEndExtensions on LighthouseBackEnd {
  bool get isPairBackEnd {
    return this is PairBackEnd;
  }
}
