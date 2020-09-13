import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DefaultCharacteristics.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/FlutterBlueExtensions.dart';

final Guid _POWER_CHARACTERISTIC = Guid('0000cb01-0000-1000-8000-00805f9b34fb');

class ViveBaseStationDevice extends BLEDevice {
  ViveBaseStationDevice(BluetoothDevice device) : super(device);

  BluetoothCharacteristic /* ? */ _characteristic;
  int /* ? */ _deviceId;
  String /* ? */ _firmwareVersion;

  @override
  String get firmwareVersion {
    if (_firmwareVersion == null) {
      return "UNKNOWN";
    } else {
      return _firmwareVersion;
    }
  }

  @override
  Future cleanupConnection() async {
    _characteristic = null;
  }

  @override
  Future<int /* ? */ > getCurrentState() async {
    if (_characteristic == null) {
      return null;
    }
    if ((await this.device.state.first) != BluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final dataArray = await _characteristic.read();
    final byteArray = ByteData(8);
    for (var i = 0; i < 8; i++) {
      byteArray.setUint8(i, dataArray[i]);
    }
    return byteArray.getUint64(0, Endian.little);
  }

  @override
  bool get hasOpenConnection {
    return _characteristic != null;
  }

  ///
  ///
  /// May throw [UnsupportedError] if state is something else than [LighthousePowerState.ON] or [LighthousePowerState.STANDBY].
  @override
  Future internalChangeState(LighthousePowerState newState) async {
    if (_characteristic == null) {
      return;
    }
    if (_deviceId == null) {
      debugPrint("Device id is null for $name (${device.id})");
      return;
    }
    final command = ByteData(20);
    command.setUint8(0, 0x12);
    switch (newState) {
      case LighthousePowerState.ON:
        command.setUint8(1, 0x00);
        command.setUint16(2, 0x0000, Endian.big);
        break;
      case LighthousePowerState.STANDBY:
        command.setUint8(1, 0x02);
        command.setUint16(2, 0x0001, Endian.big);
        break;
      default:
        throw UnsupportedError("Unsupported new state of $newState");
    }
    command.setUint32(0, _deviceId, Endian.little);

    final List<int> data = List(20);
    for (var i = 0; i < 20; i++) {
      data[i] = command.getUint8(i);
    }

    await _characteristic.write(data, withoutResponse: true);
  }

  @override
  LighthousePowerState powerStateFromByte(int byte) {
    return LighthousePowerState.UNKNOWN;
  }

  @override
  Future<bool> isValid() async {
    try {
      _deviceId = int.parse(name.replaceAll('HTC BS', '').replaceAll(' ', ''),
          radix: 16);
    } on FormatException {
      debugPrint('Could not get deviceId from name. "$name"');
      return false;
    }
    debugPrint('Connecting to device: ${this.deviceIdentifier}');
    try {
      await this.device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('Connection timed-out for device: ${this.deviceIdentifier}');
      return false;
    }

    debugPrint('Finding service for device: ${this.deviceIdentifier}');
    final List<BluetoothService> services =
        await this.device.discoverServices();
    for (final service in services) {
      // TODO: check service uuid, but I don't know it yet.
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid.toLighthouseGuid();

        if (characteristic.uuid == _POWER_CHARACTERISTIC) {
          this._characteristic = characteristic;
        }
        if (DefaultCharacteristics.FIRMWARE_REVISION_CHARACTERISTIC
            .isEqualToGuid(uuid)) {
          this._firmwareVersion = await characteristic.readString();
          this._firmwareVersion =
              this._firmwareVersion.replaceAll('\r', '').replaceAll('\n', ' ');
        }
      }
    }
    if (this._characteristic != null) {
      return true;
    }
    await disconnect();
    return false;
  }

  @override
  String get name => device.name;

  @override
  Map<String, String> get otherMetadata => Map();
}
