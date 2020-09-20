/// A enum that describes the current power state of a lighthouse beacon.
class LighthousePowerState {
  final String text;

  const LighthousePowerState._internal(this.text);

  static const SLEEP = const LighthousePowerState._internal('Sleep');
  static const ON = const LighthousePowerState._internal('On');
  static const UNKNOWN = const LighthousePowerState._internal('Unknown');
  static const BOOTING = const LighthousePowerState._internal('Booting');
}
