import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../ble/bluetooth_characteristic.dart';
import '../ble/bluetooth_device.dart';
import '../ble/bluetooth_service.dart';
import '../ble/default_characteristics.dart';
import '../ble/guid.dart';
import '../device_extensions/clear_id_extension.dart';
import '../device_extensions/device_extension.dart';
import '../device_extensions/device_with_extensions.dart';
import '../device_extensions/on_extension.dart';
import '../device_extensions/sleep_extension.dart';
import '../lighthouse_power_state.dart';
import '../widgets/vive_base_station_extra_info_alert_widget.dart';
import 'ble_device.dart';

class ViveBaseStationDevice extends BLEDevice implements DeviceWithExtensions {
  ViveBaseStationDevice(LHBluetoothDevice device, this.bloc) : super(device);

  static const String powerServiceUUID = '0000cb00-0000-1000-8000-00805f9b34fb';
  static const String powerCharacteristicUUID =
      '0000cb01-0000-1000-8000-00805f9b34fb';

  @override
  final Set<DeviceExtension> deviceExtensions = {};
  @visibleForTesting
  final LighthousePMBloc? bloc;
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

  @visibleForTesting
  int? deviceIdEndHint;
  String? _firmwareVersion;
  final BehaviorSubject<bool> _hasDeviceIdSubject =
      BehaviorSubject.seeded(false);
  final Map<String, String?> _otherMetadata = {};
  static const _supportedCharacteristicsList = [
    DefaultCharacteristics.modelNumberStringCharacteristic,
    DefaultCharacteristics.serialNumberStringCharacteristic,
    DefaultCharacteristics.hardwareRevisionCharacteristic,
    DefaultCharacteristics.manufacturerNameCharacteristic,
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
    final characteristic = _characteristic;
    if (characteristic == null) {
      return null;
    }
    if ((await device.state.first) != LHBluetoothDeviceState.connected) {
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
  /// May throw [UnsupportedError] if state is something else than [LighthousePowerState.on] or [LighthousePowerState.standby].
  ///
  @override
  Future internalChangeState(LighthousePowerState newState) async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      return;
    }
    final deviceId = _deviceId;
    if (deviceId == null) {
      debugPrint("Device id is null for $name (${device.id})");
      return;
    }
    final command = ByteData(20);
    command.setUint8(0, 0x12);
    switch (newState) {
      case LighthousePowerState.on:
        command.setUint8(1, 0x00);
        command.setUint16(2, 0x0000, Endian.big);
        break;
      case LighthousePowerState.sleep:
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
    return LighthousePowerState.unknown;
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
      final subStringLocation = name.length - 4;
      deviceIdEndHint = int.parse(name.substring(subStringLocation), radix: 16);
    } on FormatException {
      debugPrint('Could not get device id end from name. "$name"');
    }
    final viveDao = bloc;
    if (viveDao != null) {
      _deviceId =
          await viveDao.viveBaseStation.getId(deviceIdentifier.toString());
      if (_deviceId == null) {
        debugPrint('Device Id not set yet for "$name"');
      }
    } else {
      debugPrint(
          'Bloc not set for ViveBaseStationDevice, will not be able to store the state');
    }
    debugPrint('Connecting to device: $deviceIdentifier');
    try {
      await device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException {
      debugPrint('Connection timed-out for device: $deviceIdentifier');
      return false;
    } catch (e, s) {
      // other connection error
      debugPrint('Other connection error:');
      debugPrint('$e');
      debugPrint('$s');
      return false;
    }

    debugPrint('Finding service for device: $deviceIdentifier');
    final List<LHBluetoothService> services = await device.discoverServices();

    final powerCharacteristic =
        LighthouseGuid.fromString(powerCharacteristicUUID);

    for (final service in services) {
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid;

        if (uuid == powerCharacteristic) {
          _characteristic = characteristic;
          continue;
        }
        if (DefaultCharacteristics.firmwareRevisionCharacteristic
            .isEqualToGuid(uuid)) {
          try {
            final firmwareVersion = await characteristic.readString();
            _firmwareVersion =
                firmwareVersion.replaceAll('\r', '').replaceAll('\n', ' ');
          } catch (e, s) {
            debugPrint('Unable to get firmware version because: $e');
            debugPrint('$s');
          }
          continue;
        }
        await checkCharacteristicForDefaultValue(
            _supportedCharacteristicsList, characteristic, _otherMetadata);
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
    final viveDao = bloc;
    if (viveDao != null) {
      deviceExtensions.add(ClearIdExtension(
          viveDao: viveDao.viveBaseStation,
          deviceId: deviceIdentifier.toString(),
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
    LighthousePowerState lastState = LighthousePowerState.unknown;
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
        return LighthousePowerState.booting;
      }
    }).asBroadcastStream();
  }

  @override
  Future<bool> showExtraInfoWidget(BuildContext context) async {
    if (_deviceId != null) {
      return true;
    }
    final deviceIdEnd = deviceIdEndHint;

    var value = await ViveBaseStationExtraInfoAlertWidget.showCustomDialog(
        context, deviceIdEnd);
    if (value == null) {
      return false;
    }
    value = value.toUpperCase();
    if (value.length == 4 && deviceIdEnd != null) {
      value += deviceIdEnd.toRadixString(16).padLeft(4, '0').toUpperCase();
    }
    if (value.length == 8) {
      try {
        _deviceId = int.parse(value, radix: 16);
        final viveDao = bloc;
        if (viveDao != null) {
          await viveDao.viveBaseStation
              .insertId(deviceIdentifier.toString(), _deviceId!);
        } else {
          debugPrint('Could not save device id because the dao was null');
        }
        return true;
      } on FormatException {
        debugPrint('Could not convert device id to a number');
      }
    }
    return false;
  }
}