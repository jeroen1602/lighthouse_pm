part of '../../lighthouse_back_end.dart';

///
/// A device for all other devices.
///
abstract class BLEDevice<T> extends LighthouseDevice {
  BLEDevice(this.device, this.persistence);

  @visibleForTesting
  @protected
  final LHBluetoothDevice device;

  @visibleForTesting
  @protected
  final T? persistence;

  ///
  /// Disconnect form the device and call the cleanup for the superclass to also
  /// do some cleaning.
  ///
  @override
  @protected
  Future internalDisconnect() async {
    await cleanupConnection();
    await device.disconnect();
  }

  ///
  /// Clean-up any open connections that may still be lingering.
  ///
  @protected
  Future cleanupConnection();

  @override
  LHDeviceIdentifier get deviceIdentifier => device.id;

  ///
  /// Fired after the isValid method has returned true.
  ///
  void afterIsValid();

  ///
  /// If this is a valid device of the specified type.
  ///
  Future<bool> isValid();

  ///
  /// Check if the current [characteristic] is one of the
  /// [supportedCharacteristic]. If it is read the value and store it in the
  /// [metadataMap].
  ///
  @visibleForTesting
  @protected
  Future<void> checkCharacteristicForDefaultValue(
      final List<DefaultCharacteristics> supportedCharacteristic,
      final LHBluetoothCharacteristic characteristic,
      final Map<String, String?> metadataMap) async {
    final LighthouseGuid uuid = characteristic.uuid;
    for (final defaultCharacteristic in supportedCharacteristic) {
      if (defaultCharacteristic.isEqualToGuid(uuid)) {
        try {
          String? response;
          switch (defaultCharacteristic.type) {
            case int:
              final responseInt = await characteristic.readUint32();
              response = "$responseInt";
              break;
            case String:
              response = await characteristic.readString();
              break;
            default:
              lighthouseLogger
                  .warning("Unsupported type ${defaultCharacteristic.type}");
              break;
          }
          if (response != null) {
            metadataMap[defaultCharacteristic.name] = response;
          }
        } catch (e, s) {
          lighthouseLogger.severe(
              "Unable to get metadata characteristic "
              "\"${defaultCharacteristic.name}\"",
              e,
              s);
        }
      }
    }
  }
}
