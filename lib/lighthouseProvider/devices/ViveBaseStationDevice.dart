import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthousePowerState.dart';
import '../ble/BluetoothCharacteristic.dart';
import '../ble/BluetoothDevice.dart';
import '../ble/BluetoothService.dart';
import '../ble/DefaultCharacteristics.dart';
import '../ble/Guid.dart';
import '../deviceExtensions/ClearIdExtension.dart';
import '../deviceExtensions/DeviceExtension.dart';
import '../deviceExtensions/DeviceWithExtensions.dart';
import '../deviceExtensions/OnExtension.dart';
import '../deviceExtensions/SleepExtension.dart';
import '../widgets/ViveBaseStationExtraInfoAlertWidget.dart';
import 'BLEDevice.dart';

const String _POWER_CHARACTERISTIC = '0000cb01-0000-1000-8000-00805f9b34fb';

class ViveBaseStationDevice extends BLEDevice implements DeviceWithExtensions {
  ViveBaseStationDevice(LHBluetoothDevice device, ViveBaseStationBloc bloc)
      : _bloc = bloc,
        super(device);

  @override
  final Set<DeviceExtension> deviceExtensions = Set();
  final ViveBaseStationBloc /* ? */ _bloc;
  LHBluetoothCharacteristic /* ? */ _characteristic;
  int /* ? */ _deviceIdStorage;

  int /* ? */ get _deviceId => _deviceIdStorage;

  set _deviceId(int /* ? */ id) {
    _deviceIdStorage = id;
    _hasDeviceIdSubject.add(id != null);
    if (id == null) {
      _otherMetadata['Id'] = null;
    } else {
      _otherMetadata['Id'] =
          '0x${id.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
  }

  int /* ? */ _deviceIdEnd;
  String /* ? */ _firmwareVersion;
  BehaviorSubject<bool> _hasDeviceIdSubject = BehaviorSubject.seeded(false);
  final Map<String, String> _otherMetadata = Map();
  static const _SUPPORTED_CHARACTERISTICS_LIST = const [
    DefaultCharacteristics.MODEL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.SERIAL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.HARDWARE_REVISION_CHARACTERISTIC,
    DefaultCharacteristics.MANUFACTURER_NAME_CHARACTERISTIC,
  ];

  @override
  String get name => device.name;

  @override
  Map<String, String> get otherMetadata => _otherMetadata;

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
    if ((await this.device.state.first) != LHBluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final dataArray = await _characteristic.read();
    final byteArray = ByteData(min(8, dataArray.length));
    for (var i = 0; i < min(8, dataArray.length); i++) {
      byteArray.setUint8(i, dataArray[i]);
    }
    switch (byteArray.lengthInBytes) {
      case 1:
        return byteArray.getUint8(0);
      case 2:
        return byteArray.getUint16(0, Endian.big);
      case 3:
        return (byteArray.getUint16(0, Endian.big) << 8) +
            byteArray.getUint8(2);
      case 4:
        return byteArray.getUint32(0, Endian.big);
      case 5:
        return (byteArray.getUint32(0, Endian.big) << 8) +
            byteArray.getUint8(4);
      case 6:
        return (byteArray.getUint32(0, Endian.big) << 16) +
            byteArray.getUint16(4, Endian.big);
      case 7:
        return (byteArray.getUint32(0, Endian.big) << 24) +
            (byteArray.getUint16(4, Endian.big) << 8) +
            byteArray.getUint8(6);
      case 8:
      default:
        return byteArray.getUint64(0, Endian.big);
    }
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
      case LighthousePowerState.SLEEP:
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
      final idPart = name.replaceAll('HTC BS', '').replaceAll(' ', '');
      _deviceIdEnd = int.parse(idPart.substring(2), radix: 16);
    } on FormatException {
      debugPrint('Could not get device id end from name. "$name"');
      return false;
    }
    if (_bloc != null) {
      _deviceId = await _bloc.getIdOnSubset(_deviceIdEnd);
      if (_deviceId == null) {
        debugPrint('Device Id not set yet for "$name"');
      }
    } else {
      debugPrint(
          'Bloc not set for ViveBaseStationDevice, will not be able to store the state');
    }
    debugPrint('Connecting to device: ${this.deviceIdentifier}');
    try {
      await this.device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('Connection timed-out for device: ${this.deviceIdentifier}');
      return false;
    }

    debugPrint('Finding service for device: ${this.deviceIdentifier}');
    final List<LHBluetoothService> services =
        await this.device.discoverServices();

    final powerCharacteristic =
        LighthouseGuid.fromString(_POWER_CHARACTERISTIC);

    for (final service in services) {
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid;

        if (uuid == powerCharacteristic) {
          this._characteristic = characteristic;
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

  @override
  void afterIsValid() {
    // Add the extra extensions that need a valid connection to work.
    if (_bloc != null) {
      deviceExtensions.add(ClearIdExtension(
          bloc: _bloc,
          deviceIdEnd: _deviceIdEnd,
          clearId: () => _deviceId = null));
    }
    deviceExtensions.add(SleepExtension(
        changeState: changeState,
        powerStateStream: _getPowerStateStreamForExtensions()));
    deviceExtensions.add(OnExtension(
        changeState: changeState,
        powerStateStream: _getPowerStateStreamForExtensions()));
  }

  Stream<LighthousePowerState> _getPowerStateStreamForExtensions() {
    LighthousePowerState lastState = LighthousePowerState.UNKNOWN;
    bool hasId = false;
    return MergeStream<dynamic>([powerStateEnum, _hasDeviceIdSubject.stream])
        .map((event) {
      if (event is LighthousePowerState) {
        lastState = event;
      } else if (event is bool) {
        hasId = event;
      }
      if (hasId) {
        return lastState;
      } else {
        return LighthousePowerState.BOOTING;
      }
    }).asBroadcastStream();
  }

  @override
  Future<bool> showExtraInfoWidget(BuildContext context) async {
    if (this._deviceId != null) {
      return true;
    }

    return ViveBaseStationExtraInfoAlertWidget.showCustomDialog(
            context, _deviceIdEnd)
        .then((value) async {
      if (value == null) {
        return false;
      }
      value = value.toUpperCase();
      if (value.length == 4) {
        value += _deviceIdEnd.toRadixString(16).padLeft(4, '0').toUpperCase();
      }
      if (value.length == 8) {
        if (value.substring(3) ==
            _deviceIdEnd.toRadixString(16).padLeft(4, '0').toUpperCase()) {
          debugPrint('End of the device did not match');
          return false;
        }
        try {
          this._deviceId = int.parse(value, radix: 16);
          if (_bloc != null) {
            await _bloc.insertId(_deviceId);
          } else {
            debugPrint('Could not save device id because the bloc was null');
          }
          return true;
        } on FormatException {
          debugPrint('Could not convert device id to a number');
        }
      }
      return false;
    });
  }
}
