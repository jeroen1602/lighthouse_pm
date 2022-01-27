part of lighthouse_provider;

/// An enum that describes the current power state of a lighthouse beacon.
class LighthousePowerState {
  final String text;

  ///
  /// This is for storing into the data base. These should all be unique and
  /// not change between versions!
  final int id;

  const LighthousePowerState._internal(this.text, this.id);

  static const sleep = LighthousePowerState._internal('Sleep', 0);
  static const on = LighthousePowerState._internal('On', 1);
  static const unknown = LighthousePowerState._internal('Unknown', 2);
  static const booting = LighthousePowerState._internal('Booting', 3);
  static const standby = LighthousePowerState._internal('Standby', 4);

  static const values = [
    sleep,
    on,
    unknown,
    booting,
    standby,
  ];

  static LighthousePowerState fromId(int id) {
    if (id >= 0 && id < values.length) {
      return values[id];
    }
    throw ArgumentError('Unknown id provided!');
  }

  @override
  String toString() {
    return "$text ($id)";
  }
}
