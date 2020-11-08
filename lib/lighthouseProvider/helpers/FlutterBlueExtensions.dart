///
/// Extensions for the flutter blue classes.
///

import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';

import '../ble/BluetoothDevice.dart';
import '../ble/DeviceIdentifier.dart';
import '../ble/Guid.dart';

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
    return LighthouseGuid.fromBytes(this.toByteData());
  }
}

extension DeviceIdentifierExtensions on DeviceIdentifier {
  LHDeviceIdentifier toLHDeviceIdentifier() {
    return LHDeviceIdentifier(this.id);
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
