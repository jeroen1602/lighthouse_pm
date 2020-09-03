import 'package:flutter/foundation.dart';

/// A enum that describes the current power state of a lighthouse beacon.
class LighthousePowerState {
  final String text;
  final int setByte;
  final int stateByte;

  const LighthousePowerState._internal(this.text, this.setByte, this.stateByte);

  static const STANDBY = const LighthousePowerState._internal('Standby', 0x00, 0x00);
  static const ON = const LighthousePowerState._internal('On', 0x01, 0x0b);
  static const UNKNOWN = const LighthousePowerState._internal('Unknown', null, null);
  static const BOOTING = const LighthousePowerState._internal('Booting', null, 0x09);

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
      default:
        return LighthousePowerState.UNKNOWN;
    }
  }
}
