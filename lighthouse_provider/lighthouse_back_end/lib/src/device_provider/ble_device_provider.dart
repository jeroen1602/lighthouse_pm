part of lighthouse_back_end;

///
/// An abstract device provider specifically made for Bluetooth low energy.
///
abstract class BLEDeviceProvider<T> extends DeviceProvider<LHBluetoothDevice> {
  @visibleForTesting
  Set<BLEDevice> bleDevicesDiscovering = {};

  @visibleForTesting
  @protected
  T? persistence;

  ///
  /// Set the database persistence for saving the ids of vive base stations.
  /// Not every provider requires this.
  ///
  void setPersistence(final T persistence) {
    this.persistence = persistence;
  }

  ///
  /// Make sure a persistence instance exists.
  ///
  @visibleForTesting
  @protected
  T requirePersistence() {
    assert(() {
      if (persistence == null) {
        throw StateError('Persistence is null');
      }
      return true;
    }());
    return persistence!;
  }

  ///
  /// Connect to a device and return a super class of [LighthouseDevice].
  ///
  /// [device] the specific device to connect to and test.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  @override
  Future<LighthouseDevice?> getDevice(final LHBluetoothDevice device,
      {final Duration? updateInterval}) async {
    final BLEDevice bleDevice = await internalGetDevice(device);
    if (updateInterval != null) {
      bleDevice.setUpdateInterval(updateInterval);
    }
    bleDevicesDiscovering.add(bleDevice);
    try {
      final valid = await bleDevice.isValid();
      bleDevicesDiscovering.remove(bleDevice);
      if (valid) {
        bleDevice.afterIsValid();
      } else {
        await bleDevice.disconnect();
      }
      return valid ? bleDevice : null;
    } catch (e, s) {
      print('$e');
      print('$s');
      try {
        await bleDevice.disconnect();
      } catch (e, s) {
        print(
            "Failed to disconnect, maybe already disconnected\n$e\n$s\n======\n");
      }
      return null;
    }
  }

  ///
  /// Any subclass should extend this and return a [BLEDevice] back.
  ///
  @protected
  Future<BLEDevice> internalGetDevice(final LHBluetoothDevice device);

  ///
  /// Close any open connections that may have been made for discovering devices.
  ///
  @override
  Future disconnectRunningDiscoveries() async {
    final Set<BLEDevice> discovering = {};
    discovering.addAll(bleDevicesDiscovering);
    for (final device in discovering) {
      try {
        await device.disconnect();
      } catch (e, s) {
        print("Could not disconnect device (${device.name}, "
            "${device.deviceIdentifier.toString()}), maybe the device is "
            "already disconnected? Error:\n$s\n$s");
      }
    }
    bleDevicesDiscovering.clear();
  }
}
