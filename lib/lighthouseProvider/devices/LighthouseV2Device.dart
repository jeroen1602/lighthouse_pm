import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DefaultCharacteristics.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/FlutterBlueExtensions.dart';

///The bluetooth service that handles the power state of the device.
final Guid _POWER_SERVICE = Guid('00001523-1212-efde-1523-785feabcd124');

///The characteristic that handles the power state of the device.
final Guid _POWER_CHARACTERISTIC = Guid('00001525-1212-efde-1523-785feabcd124');

class LighthouseV2Device extends BLEDevice {
  LighthouseV2Device(BluetoothDevice device) : super(device);

  BluetoothCharacteristic /* ? */ _characteristic;
  String /* ? */ _firmwareVersion;
  final Map<String, String> _otherMetadata = Map();
  static const _SUPPORTED_CHARACTERISTICS_LIST = const [
    DefaultCharacteristics.MODEL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.SERIAL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.HARDWARE_REVISION_CHARACTERISTIC,
    DefaultCharacteristics.MANUFACTURER_NAME_CHARACTERISTIC,
  ];

  @override
  String get firmwareVersion {
    if (_firmwareVersion == null) {
      return "UNKNOWN";
    } else {
      return _firmwareVersion;
    }
  }

  @override
  Map<String, String> get otherMetadata => _otherMetadata;

  @override
  Future<int /*?*/ > getCurrentState() async {
    if (_characteristic == null) {
      return null;
    }
    if ((await this.device.state.first) != BluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final dataArray = await _characteristic.read();
    if (dataArray.length >= 1) {
      return dataArray[0];
    }
    return null;
  }

  @override
  bool get hasOpenConnection {
    return (_characteristic != null);
  }

  @override
  LighthousePowerState powerStateFromByte(int byte) {
    if (byte < 0x0 || byte > 0xff) {
      debugPrint(
          'Byte was lower than 0x00 or higher than 0xff. actual value: 0x${byte.toRadixString(16)}');
    }

    switch (byte) {
      case 0x00:
        return LighthousePowerState.SLEEP;
      case 0x0b:
        return LighthousePowerState.ON;
      case 0x01:
      case 0x09:
        return LighthousePowerState.BOOTING;
      default:
        return LighthousePowerState.UNKNOWN;
    }
  }

  @override
  Future<bool> isValid() async {
    debugPrint('Connecting to device: ${this.deviceIdentifier}');
    await this.device.connect(timeout: Duration(seconds: 10)).catchError((e) {
      debugPrint('Connection timed-out for device: ${this.deviceIdentifier}');
      return false;
    }, test: (e) => e is TimeoutException);

    debugPrint('Finding service for device: ${this.deviceIdentifier}');
    final List<BluetoothService> services =
        await this.device.discoverServices();
    for (final service in services) {
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
        for (final defaultCharacteristic in _SUPPORTED_CHARACTERISTICS_LIST) {
          if (defaultCharacteristic.isEqualToGuid(uuid)) {
            String response;
            switch (defaultCharacteristic.type) {
              case int:
                final responseInt = await characteristic.readUint32();
                response = "$responseInt";
                break;
              case String:
                response = await characteristic.readString();
                break;
              default:
                debugPrint('Unsupported type ${defaultCharacteristic.type}');
                break;
            }
            if (response != null) {
              _otherMetadata[defaultCharacteristic.name] = response;
            }
          }
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
  Future cleanupConnection() async {
    this._characteristic = null;
  }

  @override
  Future internalChangeState(LighthousePowerState newState) async {
    if (this._characteristic != null) {
      switch (newState) {
        case LighthousePowerState.ON:
          await this._characteristic.write([0x01], withoutResponse: true);
          break;
        case LighthousePowerState.SLEEP:
          await this._characteristic.write([0x00], withoutResponse: true);
          break;
      }
    }
  }
}
