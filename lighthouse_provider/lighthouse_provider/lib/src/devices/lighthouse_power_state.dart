part of '../../lighthouse_provider.dart';

/// An enum that describes the current power state of a lighthouse beacon.
///
enum LighthousePowerState {
  sleep('Sleep'),
  on('On'),
  unknown('Unknown'),
  booting('Booting'),
  standby('Standby'),
  ;

  final String text;

  const LighthousePowerState(this.text);

  static LighthousePowerState fromId(final int id) {
    if (id >= 0 && id < values.length) {
      return values[id];
    }
    throw ArgumentError('Unknown id provided!');
  }

  @override
  String toString() {
    return "$text ($index)";
  }
}
