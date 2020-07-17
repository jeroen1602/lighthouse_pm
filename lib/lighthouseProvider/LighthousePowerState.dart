import 'package:flutter/foundation.dart';

/// A enum that describes the current power state of a lighthouse beacon.
class LighthousePowerState {
  final String text;
  final int byte;

  const LighthousePowerState._internal(this.text, this.byte);

  static const STANDBY = const LighthousePowerState._internal('Standby', 0x00);
  static const ON = const LighthousePowerState._internal('On', 0x01);
  static const UNKNOWN = const LighthousePowerState._internal('Unknown', null);
  static const BOOTING = const LighthousePowerState._internal('Booting', null);

  /// Convert a power state byte into a power state enum item.
  ///
  /// If the byte is lower than `0x00` or higher than `0xFF` then this will be
  /// logged to the debug console and return [LighthousePowerState.UNKNOWN].
  /// If an unknown state is used (e.g. a state byte that is unknown for us)
  /// then [LighthousePowerState.UNKNOWN] is returned and nothing is logged.
  static LighthousePowerState fromByte(int byte) {
    if (byte < 0x0 || byte > 0xff) {
      debugPrint(
          'Byte was lower than 0x00 or higher than 0xff. actual value: 0x${byte.toRadixString(16)}');
    }
    switch (byte) {
      case 0x00:
        return LighthousePowerState.STANDBY;
      case 0x0b:
        return LighthousePowerState.ON;
      case 0x01:
      case 0x09:
        return LighthousePowerState.BOOTING;
      case 0x0b:
      default:
        return LighthousePowerState.UNKNOWN;
    }
  }
}
