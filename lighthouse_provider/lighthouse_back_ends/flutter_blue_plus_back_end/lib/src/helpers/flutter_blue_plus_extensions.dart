part of flutter_blue_plus_back_end;

///
/// Extensions for the flutter blue plus classes.
///

extension GuidByteData on blue_plus.Guid {
  LighthouseGuid toLighthouseGuid() {
    return LighthouseGuid.fromString(str128);
  }
}

extension DeviceIdentifierExtensions on blue_plus.DeviceIdentifier {
  LHDeviceIdentifier toLHDeviceIdentifier() {
    if (SharedPlatform.isAndroid) {
      return LHDeviceIdentifier(str.toUpperCase());
    }
    return LHDeviceIdentifier(str);
  }
}

extension BluetoothDeviceStateExtensions on blue_plus.BluetoothConnectionState {
  LHBluetoothDeviceState toLHState() {
    switch (this) {
      case blue_plus.BluetoothConnectionState.disconnected:
        return LHBluetoothDeviceState.disconnected;
      case blue_plus.BluetoothConnectionState.connected:
        return LHBluetoothDeviceState.connected;
      default:
        return LHBluetoothDeviceState.unknown;
    }
  }
}
