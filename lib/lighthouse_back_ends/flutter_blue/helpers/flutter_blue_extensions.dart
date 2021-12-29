part of flutter_blue_back_end;

///
/// Extensions for the flutter blue classes.
///

extension GuidByteData on Guid {
  ByteData toByteData() {
    final list = toByteArray();
    final output = ByteData(list.length);
    for (var i = 0; i < list.length; i++) {
      output.setUint8(i, list[i]);
    }
    return output;
  }

  LighthouseGuid toLighthouseGuid() {
    return LighthouseGuid.fromBytes(toByteData());
  }
}

extension DeviceIdentifierExtensions on DeviceIdentifier {
  LHDeviceIdentifier toLHDeviceIdentifier() {
    if (LocalPlatform.isAndroid) {
      return LHDeviceIdentifier(id.toUpperCase());
    }
    return LHDeviceIdentifier(id);
  }
}

extension BluetoothDeviceStateExtensions on BluetoothDeviceState {
  LHBluetoothDeviceState toLHState() {
    switch (this) {
      case BluetoothDeviceState.connected:
        return LHBluetoothDeviceState.connected;
      case BluetoothDeviceState.connecting:
        return LHBluetoothDeviceState.connecting;
      case BluetoothDeviceState.disconnected:
        return LHBluetoothDeviceState.disconnected;
      case BluetoothDeviceState.disconnecting:
        return LHBluetoothDeviceState.disconnecting;
      default:
        return LHBluetoothDeviceState.unknown;
    }
  }
}
