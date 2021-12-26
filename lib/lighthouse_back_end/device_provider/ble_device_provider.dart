part of lighthouse_back_end;

///
/// An abstract device provider specifically made for Bluetooth low energy.
///
abstract class BLEDeviceProvider extends DeviceProvider<LHBluetoothDevice> {
  @visibleForTesting
  Set<BLEDevice> bleDevicesDiscovering = {};

  @visibleForTesting
  @protected
  LighthousePMBloc? bloc;

  ///
  /// Set the database bloc for saving the ids of vive base stations.
  /// Not every provider requires this.
  ///
  void setBloc(LighthousePMBloc bloc) {
    this.bloc = bloc;
  }

  ///
  /// Make sure a bloc instance exists.
  ///
  @visibleForTesting
  @protected
  LighthousePMBloc requireBloc() {
    if (bloc == null && !kReleaseMode) {
      throw StateError('Bloc is null');
    }
    return bloc!;
  }

  ///
  /// Connect to a device and return a super class of [LighthouseDevice].
  ///
  /// [device] the specific device to connect to and test.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  @override
  Future<LighthouseDevice?> getDevice(LHBluetoothDevice device,
      {Duration? updateInterval}) async {
    BLEDevice bleDevice = await internalGetDevice(device);
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
      debugPrint('$e');
      debugPrint('$s');
      try {
        await bleDevice.disconnect();
      } catch (e, s) {
        debugPrint(
            "Failed to disconnect, maybe already disconnected\n$e\n$s\n======\n");
      }
      return null;
    }
  }

  ///
  /// Any subclass should extend this and return a [BLEDevice] back.
  ///
  @protected
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device);

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
        debugPrint("Could not disconnect device (${device.name}, "
            "${device.deviceIdentifier.toString()}), maybe the device is "
            "already disconnected? Error:\n$s\n$s");
      }
    }
    bleDevicesDiscovering.clear();
  }
}
