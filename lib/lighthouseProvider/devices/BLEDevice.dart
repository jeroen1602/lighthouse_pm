import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDeviceV2.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';

///
/// A device for all other devices.
///
abstract class BLEDevice extends LighthouseDeviceV2 {
  BLEDevice(this.device);

  @protected
  final BluetoothDevice device;

  ///
  /// Disconnect form the device and call the cleanup for the superclass to also
  /// do some cleaning.
  ///
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
  LHDeviceIdentifier get deviceIdentifier =>
      LHDeviceIdentifier.fromFlutterBlue(device.id);

  ///
  /// If this is a valid device of the specified type.
  ///
  Future<bool> isValid();
}
