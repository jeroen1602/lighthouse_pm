import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';

///
/// Some default Bluetooth Low Energy characteristics. That most devices support
///
class DefaultCharacteristics {
  final int uuid;
  final Type type;
  final String name;

  const DefaultCharacteristics(this.uuid, this.type, this.name);

  static const MODEL_NUMBER_STRING_CHARACTERISTIC =
      DefaultCharacteristics(0x00002A24, int, "Model number");
  static const SERIAL_NUMBER_STRING_CHARACTERISTIC =
      DefaultCharacteristics(0x00002A25, int, "Serial number");
  static const FIRMWARE_REVISION_CHARACTERISTIC =
      DefaultCharacteristics(0x00002A26, String, "Firmware revision");
  static const HARDWARE_REVISION_CHARACTERISTIC =
      DefaultCharacteristics(0x00002A27, String, "Hardware revision");

  static const MANUFACTURER_NAME_CHARACTERISTIC =
      DefaultCharacteristics(0x0002A29, String, "Manufacturer name");

  bool isEqualToGuid(LighthouseGuid guid) {
    if (!(guid is Guid32)) {
      guid = Guid32.fromLighthouseGuid(guid);
    }
    final Guid32 guid32 = guid as Guid32;
    return guid32.isEqualToInt32(uuid);
  }
}
