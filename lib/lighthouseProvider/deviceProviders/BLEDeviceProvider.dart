import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';

import '../DeviceProvider.dart';
import '../LighthouseDeviceV2.dart';

///
/// An abstract device provider specifically made for Bluetooth low energy.
///
abstract class BLEDeviceProvider extends DeviceProvider<BluetoothDevice> {
  Set<BLEDevice> _bleDevicesDiscovering = Set();

  ///
  /// Connect to a device and return a super class of [LighthouseDeviceV2].
  ///
  /// [device] the specific device to connect to and test.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  @override
  Future<LighthouseDeviceV2 /*?*/ > getDevice(BluetoothDevice device) async {
    BLEDevice bleDevice = await this.internalGetDevice(device);
    this._bleDevicesDiscovering.add(bleDevice);
    try {
      final valid = await bleDevice.isValid();
      this._bleDevicesDiscovering.remove(bleDevice);
      return valid ? bleDevice : null;
    } catch (e, s) {
      debugPrint('$e');
      debugPrint('$s');
      return null;
    }
  }

  ///
  /// Any subclass should extend this and return a [BLEDevice] back.
  ///
  @protected
  Future<BLEDevice> internalGetDevice(BluetoothDevice device);

  ///
  /// Close any open connections that may have been made for discovering devices.
  ///
  @override
  Future disconnectRunningDiscoveries() async {
    final Set<BLEDevice> discovering = Set();
    discovering.addAll(_bleDevicesDiscovering);
    for (final device in discovering) {
      await device.disconnect();
    }
    _bleDevicesDiscovering.clear();
  }
}
