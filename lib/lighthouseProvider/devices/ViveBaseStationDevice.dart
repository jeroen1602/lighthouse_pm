import 'dart:async';
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
  final ViveBaseStationBloc? _bloc;
  LHBluetoothCharacteristic? _characteristic;
  int? _deviceIdStorage;

  int? get _deviceId => _deviceIdStorage;

  set _deviceId(int? id) {
    _deviceIdStorage = id;
    _hasDeviceIdSubject.add(id != null);
    if (id == null) {
      _otherMetadata['Id'] = null;
    } else {
      _otherMetadata['Id'] =
          '0x${id.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
  }

  int? _deviceIdEnd;
  String? _firmwareVersion;
  BehaviorSubject<bool> _hasDeviceIdSubject = BehaviorSubject.seeded(false);
  final Map<String, String?> _otherMetadata = Map();
  static const _SUPPORTED_CHARACTERISTICS_LIST = const [
    DefaultCharacteristics.MODEL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.SERIAL_NUMBER_STRING_CHARACTERISTIC,
    DefaultCharacteristics.HARDWARE_REVISION_CHARACTERISTIC,
    DefaultCharacteristics.MANUFACTURER_NAME_CHARACTERISTIC,
  ];

  @override
  String get name => device.name;

  @override
  Map<String, String?> get otherMetadata => _otherMetadata;

  @override
  String get firmwareVersion {
    return _firmwareVersion ?? "UNKNOWN";
  }

  @override
  Future cleanupConnection() async {
    _characteristic = null;
  }

  @override
  Future<int?> getCurrentState() async {
    final characteristic = this._characteristic;
    if (characteristic == null) {
      return null;
    }
    if ((await this.device.state.first) != LHBluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final byteArray = await characteristic.readByteData();

    if (byteArray.lengthInBytes >= 2) {
      return byteArray.getUint8(1);
    } else if (byteArray.lengthInBytes >= 1) {
      return byteArray.getUint8(0);
    } else {
      return null;
    }
  }

  @override
  bool get hasOpenConnection {
    return _characteristic != null;
  }

  ///
  /// May throw [UnsupportedError] if state is something else than [LighthousePowerState.ON] or [LighthousePowerState.STANDBY].
  ///
  @override
  Future internalChangeState(LighthousePowerState newState) async {
    final characteristic = this._characteristic;
    if (characteristic == null) {
      return;
    }
    final deviceId = this._deviceId;
    if (deviceId == null) {
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
    command.setUint32(4, deviceId, Endian.little);

    await characteristic.writeByteData(command, withoutResponse: true);
  }

  @override
  LighthousePowerState powerStateFromByte(int byte) {
    // revert back to unknown, still needs some research.
    return LighthousePowerState.UNKNOWN;
    // switch (byte) {
    //   case 0x15:
    //     return LighthousePowerState.ON;
    //   case 0x12:
    //     return LighthousePowerState.SLEEP;
    //   default:
    //     return LighthousePowerState.UNKNOWN;
    // }
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
    final bloc = _bloc;
    if (bloc != null) {
      this._deviceId = await bloc.getIdOnSubset(_deviceIdEnd!);
      if (this._deviceId == null) {
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
            final firmwareVersion = await characteristic.readString();
            this._firmwareVersion =
                firmwareVersion.replaceAll('\r', '').replaceAll('\n', ' ');
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
    if (hasOpenConnection) {
      return true;
    }
    await disconnect();
    return false;
  }

  @override
  void afterIsValid() {
    // Add the extra extensions that need a valid connection to work.
    final bloc = _bloc;
    if (bloc != null) {
      deviceExtensions.add(ClearIdExtension(
          bloc: bloc,
          deviceIdEnd: _deviceIdEnd!,
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
            context, _deviceIdEnd!)
        .then((value) async {
      if (value == null) {
        return false;
      }
      value = value.toUpperCase();
      if (value.length == 4) {
        value += _deviceIdEnd!.toRadixString(16).padLeft(4, '0').toUpperCase();
      }
      if (value.length == 8) {
        if (value.substring(3) ==
            _deviceIdEnd!.toRadixString(16).padLeft(4, '0').toUpperCase()) {
          debugPrint('End of the device did not match');
          return false;
        }
        try {
          this._deviceId = int.parse(value, radix: 16);
          final bloc = _bloc;
          if (bloc != null) {
            await bloc.insertId(_deviceId!);
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
