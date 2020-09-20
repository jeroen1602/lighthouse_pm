import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DefaultCharacteristics.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceExtensions.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceWithExtensions.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/IdentifyDeviceExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/FlutterBlueExtensions.dart';

///The bluetooth service that handles the power state of the device.
// final Guid _POWER_SERVICE = Guid('00001523-1212-efde-1523-785feabcd124');

///The characteristic that handles the power state of the device.
const String _POWER_CHARACTERISTIC = '00001525-1212-efde-1523-785feabcd124';

const String _CHANNEL_CHARACTERISTIC = '00001524-1212-EFDE-1523-785FEABCD124';

const String _IDENTIFY_CHARACTERISTIC = '00008421-1212-EFDE-1523-785FEABCD124';

class LighthouseV2Device extends BLEDevice implements DeviceWithExtensions {
  LighthouseV2Device(BluetoothDevice device) : super(device) {
    deviceExtensions.add(IdentifyDeviceExtension(onTap: identify));
  }

  @override
  final Set<DeviceExtensions> deviceExtensions = Set();
  BluetoothCharacteristic /* ? */ _characteristic;
  BluetoothCharacteristic /* ? */ _identifyCharacteristic;
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

    final powerCharacteristic =
        LighthouseGuid.fromString(_POWER_CHARACTERISTIC);
    final channelCharacteristic =
        LighthouseGuid.fromString(_CHANNEL_CHARACTERISTIC);
    final identifyCharacteristic =
        LighthouseGuid.fromString(_IDENTIFY_CHARACTERISTIC);

    debugPrint('Finding service for device: ${this.deviceIdentifier}');
    final List<BluetoothService> services =
        await this.device.discoverServices();
    for (final service in services) {
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid.toLighthouseGuid();

        if (uuid == powerCharacteristic) {
          this._characteristic = characteristic;
          continue;
        }
        if (uuid == identifyCharacteristic) {
          this._identifyCharacteristic = characteristic;
          continue;
        }
        if (uuid == channelCharacteristic) {
          try {
            final channel = await characteristic.readUint32();
            _otherMetadata['Channel'] = channel.toString();
          } catch (e, s) {
            debugPrint('Unable to get channel because: $e');
            debugPrint('$s');
          }
          continue;
        }

        if (DefaultCharacteristics.FIRMWARE_REVISION_CHARACTERISTIC
            .isEqualToGuid(uuid)) {
          try {
            this._firmwareVersion = await characteristic.readString();
            this._firmwareVersion = this
                ._firmwareVersion
                .replaceAll('\r', '')
                .replaceAll('\n', ' ');
          } catch (e, s) {
            debugPrint('Unable to get firmware version because: $e');
            debugPrint('$s');
          }
          continue;
        }
        for (final defaultCharacteristic in _SUPPORTED_CHARACTERISTICS_LIST) {
          if (defaultCharacteristic.isEqualToGuid(uuid)) {
            try {
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
            } catch (e, s) {
              debugPrint(
                  'Unable to get metadata characteristic "${defaultCharacteristic.name}", because $e');
              debugPrint('$s');
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

  /// Identify the current lighthouse by way of blinking the front LED.
  Future<void> identify() async {
    if (this._identifyCharacteristic == null) {
      debugPrint('No identify characteristic set!');
      return;
    }
    await transactionMutex.acquire();
    // Write any byte to the characteristic to start the identify option.
    await this._identifyCharacteristic.write([0x00]);
    transactionMutex.release();
  }
}
