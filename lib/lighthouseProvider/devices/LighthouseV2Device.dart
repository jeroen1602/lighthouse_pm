import 'dart:async';

import 'package:flutter/foundation.dart';

import '../LighthousePowerState.dart';
import '../ble/BluetoothCharacteristic.dart';
import '../ble/BluetoothDevice.dart';
import '../ble/BluetoothService.dart';
import '../ble/DefaultCharacteristics.dart';
import '../ble/Guid.dart';
import '../deviceExtensions/DeviceExtension.dart';
import '../deviceExtensions/DeviceWithExtensions.dart';
import '../deviceExtensions/IdentifyDeviceExtension.dart';
import '../deviceExtensions/OnExtension.dart';
import '../deviceExtensions/SleepExtension.dart';
import '../deviceExtensions/StandbyExtension.dart';
import 'BLEDevice.dart';

///The bluetooth service that handles the power state of the device.
// final String _POWER_SERVICE = '00001523-1212-efde-1523-785feabcd124';

///The characteristic that handles the power state of the device.
const String _POWER_CHARACTERISTIC = '00001525-1212-efde-1523-785feabcd124';

const String _CHANNEL_CHARACTERISTIC = '00001524-1212-EFDE-1523-785FEABCD124';

const String _IDENTIFY_CHARACTERISTIC = '00008421-1212-EFDE-1523-785FEABCD124';

class LighthouseV2Device extends BLEDevice implements DeviceWithExtensions {
  LighthouseV2Device(LHBluetoothDevice device) : super(device) {
    // Add a part of the [DeviceExtenion]s the rest are added after [afterIsValid].
    deviceExtensions.add(IdentifyDeviceExtension(onTap: identify));
  }

  @override
  final Set<DeviceExtension> deviceExtensions = Set();
  LHBluetoothCharacteristic? _characteristic;
  LHBluetoothCharacteristic? _identifyCharacteristic;
  String? _firmwareVersion;
  final Map<String, String> _otherMetadata = Map();
  static const _SUPPORTED_CHARACTERISTICS_LIST = const [
    DefaultCharacteristics.MODEL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.SERIAL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.HARDWARE_REVISION_CHARACTERISTIC,
    DefaultCharacteristics.MANUFACTURER_NAME_CHARACTERISTIC,
  ];

  IdentifyDeviceExtension get _identifyDeviceExtension => (deviceExtensions
          .firstWhere((element) => element is IdentifyDeviceExtension)
      as IdentifyDeviceExtension);

  @override
  String get firmwareVersion {
    return _firmwareVersion ?? "UNKNOWN";
  }

  @override
  Map<String, String> get otherMetadata => _otherMetadata;

  @override
  Future<int?> getCurrentState() async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      return null;
    }
    if ((await this.device.state.first) != LHBluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final dataArray = await characteristic.read();
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
      case 0x02:
        return LighthousePowerState.STANDBY;
      case 0x0b:
        return LighthousePowerState.ON;
      case 0x01:
      case 0x08:
      case 0x09:
        return LighthousePowerState.BOOTING;
      default:
        return LighthousePowerState.UNKNOWN;
    }
  }

  @override
  Future<bool> isValid() async {
    debugPrint('Connecting to device: ${this.deviceIdentifier}');
    try {
      await this.device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('Connection timed-out for device: ${this.deviceIdentifier}');
      return false;
    }
    _identifyDeviceExtension.setEnabled(false);

    final powerCharacteristic =
        LighthouseGuid.fromString(_POWER_CHARACTERISTIC);
    final channelCharacteristic =
        LighthouseGuid.fromString(_CHANNEL_CHARACTERISTIC);
    final identifyCharacteristic =
        LighthouseGuid.fromString(_IDENTIFY_CHARACTERISTIC);

    debugPrint('Finding service for device: ${this.deviceIdentifier}');
    final List<LHBluetoothService> services =
        await this.device.discoverServices();
    for (final service in services) {
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid;

        if (uuid == powerCharacteristic) {
          this._characteristic = characteristic;
          continue;
        }
        if (uuid == identifyCharacteristic) {
          this._identifyCharacteristic = characteristic;
          _identifyDeviceExtension.setEnabled(true);
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
            final firmware = await characteristic.readString();
            this._firmwareVersion =
                firmware.replaceAll('\r', '').replaceAll('\n', ' ');
          } catch (e, s) {
            debugPrint('Unable to get firmware version because: $e');
            debugPrint('$s');
          }
          continue;
        }
        await checkCharacteristicForDefaultValue(
            _SUPPORTED_CHARACTERISTICS_LIST, characteristic, _otherMetadata);
      }
    }
    if (this._characteristic != null) {
      return true;
    }
    await disconnect();
    return false;
  }

  void afterIsValid() {
    // Add the extra extensions that need a valid connection to work.
    deviceExtensions.add(StandbyExtension(
        changeState: changeState, powerStateStream: powerStateEnum));
    deviceExtensions.add(SleepExtension(
        changeState: changeState, powerStateStream: powerStateEnum));
    deviceExtensions.add(OnExtension(
        changeState: changeState, powerStateStream: powerStateEnum));
  }

  @override
  String get name => device.name;

  @override
  Future cleanupConnection() async {
    await _identifyDeviceExtension.close();
    this._characteristic = null;
    this._identifyCharacteristic = null;
  }

  @override
  Future internalChangeState(LighthousePowerState newState) async {
    final characteristic = this._characteristic;
    if (characteristic != null) {
      switch (newState) {
        case LighthousePowerState.ON:
          await characteristic.write([0x01], withoutResponse: true);
          break;
        case LighthousePowerState.SLEEP:
          await characteristic.write([0x00], withoutResponse: true);
          break;
        case LighthousePowerState.STANDBY:
          await characteristic.write([0x02], withoutResponse: true);
          break;
      }
    }
  }

  /// Identify the current lighthouse by way of blinking the front LED.
  Future<void> identify() async {
    final identifyCharacteristic = _identifyCharacteristic;
    if (identifyCharacteristic == null) {
      debugPrint('No identify characteristic set!');
      return;
    }
    try {
      await transactionMutex.acquire();
      // Write any byte to the characteristic to start the identify option.
      await identifyCharacteristic.write([0x00], withoutResponse: true);
    } finally {
      transactionMutex.release();
    }
  }
}
