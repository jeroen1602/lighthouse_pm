part of '../../../lighthouse_v2_device_provider.dart';

///The bluetooth service that handles the power state of the device.
// final String _poserService = '00001523-1212-efde-1523-785feabcd124';

///The characteristic that handles the power state of the device.

class LighthouseV2Device extends BLEDevice<LighthouseV2Persistence>
    with StatefulLighthouseDevice
    implements DeviceWithExtensions {
  static const String powerCharacteristicUUID =
      '00001525-1212-efde-1523-785feabcd124';

  static const String channelCharacteristicUUID =
      '00001524-1212-EFDE-1523-785FEABCD124';

  static const String identifyCharacteristicUUID =
      '00008421-1212-EFDE-1523-785FEABCD124';

  static const String controlServiceUUID =
      "00001523-1212-efde-1523-785feabcd124";

  LighthouseV2Device(super.device, super.persistence,
      [final CreateShortcutCallback? createShortcut])
      : _createShortcut = createShortcut {
    // Add a part of the [DeviceExtension]s the rest are added after [afterIsValid].
    deviceExtensions.add(IdentifyDeviceExtension(onTap: identify));
  }

  final CreateShortcutCallback? _createShortcut;
  @override
  final Set<DeviceExtension> deviceExtensions = {};
  LHBluetoothCharacteristic? _characteristic;
  LHBluetoothCharacteristic? _identifyCharacteristic;
  String? _firmwareVersion;
  final Map<String, String> _otherMetadata = {};
  static const _supportedCharacteristicsList = [
    DefaultCharacteristics.modelNumberStringCharacteristic,
    DefaultCharacteristics.serialNumberStringCharacteristic,
    DefaultCharacteristics.hardwareRevisionCharacteristic,
    DefaultCharacteristics.manufacturerNameCharacteristic,
  ];

  IdentifyDeviceExtension get _identifyDeviceExtension => (deviceExtensions
          .firstWhere((final element) => element is IdentifyDeviceExtension)
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
    if ((await device.state.first) != LHBluetoothDeviceState.connected) {
      await disconnect();
      return null;
    }
    final dataArray = await characteristic.read();
    if (dataArray.isNotEmpty) {
      return dataArray[0];
    }
    return null;
  }

  @override
  bool get hasOpenConnection {
    return (_characteristic != null);
  }

  @override
  LighthousePowerState powerStateFromByte(final int byte) {
    switch (byte) {
      case 0x00:
        return LighthousePowerState.sleep;
      case 0x02:
        return LighthousePowerState.standby;
      case 0x0b:
        return LighthousePowerState.on;
      case 0x01:
      case 0x08:
      case 0x09:
        return LighthousePowerState.booting;
      default:
        return LighthousePowerState.unknown;
    }
  }

  @override
  Future<bool> isValid() async {
    lighthouseLogger.info("Connecting to device: $deviceIdentifier");
    try {
      await device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException catch (e, s) {
      lighthouseLogger.warning(
          "Connection timed-out for device: $deviceIdentifier", e, s);
      return false;
    } catch (e, s) {
      // other connection error
      lighthouseLogger.severe("Other connection error", e, s);
      return false;
    }
    _identifyDeviceExtension.setEnabled(false);

    final powerCharacteristic =
        LighthouseGuid.fromString(powerCharacteristicUUID);
    final channelCharacteristic =
        LighthouseGuid.fromString(channelCharacteristicUUID);
    final identifyCharacteristic =
        LighthouseGuid.fromString(identifyCharacteristicUUID);

    lighthouseLogger.info("Finding services for device: $deviceIdentifier");
    final List<LHBluetoothService> services = await device.discoverServices();
    for (final service in services) {
      // Find the correct characteristic.
      for (final characteristic in service.characteristics) {
        final uuid = characteristic.uuid;

        if (uuid == powerCharacteristic) {
          _characteristic = characteristic;
          continue;
        }
        if (uuid == identifyCharacteristic) {
          _identifyCharacteristic = characteristic;
          _identifyDeviceExtension.setEnabled(true);
          continue;
        }
        if (uuid == channelCharacteristic) {
          try {
            final channel = await characteristic.readUint32();
            _otherMetadata['Channel'] = channel.toString();
          } catch (e, s) {
            lighthouseLogger.severe("Unable to get channel", e, s);
          }
          continue;
        }

        if (DefaultCharacteristics.firmwareRevisionCharacteristic
            .isEqualToGuid(uuid)) {
          try {
            final firmware = await characteristic.readString();
            _firmwareVersion =
                firmware.replaceAll('\r', '').replaceAll('\n', ' ');
          } catch (e, s) {
            lighthouseLogger.severe("Unable to get firmware version", e, s);
          }
          continue;
        }
        await checkCharacteristicForDefaultValue(
            _supportedCharacteristicsList, characteristic, _otherMetadata);
      }
    }
    if (_characteristic != null) {
      return true;
    }
    await disconnect();
    return false;
  }

  @override
  void afterIsValid() {
    // Add the extra extensions that need a valid connection to work.
    deviceExtensions.add(StandbyExtension(
        changeState: changeState, powerStateStream: () => powerStateEnum));
    deviceExtensions.add(SleepExtension(
        changeState: changeState, powerStateStream: () => powerStateEnum));
    deviceExtensions.add(OnExtension(
        changeState: changeState, powerStateStream: () => powerStateEnum));

    final callback = _createShortcut;
    if (SharedPlatform.isAndroid && callback != null) {
      persistence?.areShortcutsEnabled().then((final value) {
        if (value) {
          deviceExtensions
              .add(ShortcutExtension(deviceIdentifier.toString(), () {
            return nicknameInternal ?? name;
          }, callback));
        }
      });
    }
  }

  @override
  String get name => device.name;

  @override
  Future cleanupConnection() async {
    await _identifyDeviceExtension.close();
    _characteristic = null;
    _identifyCharacteristic = null;
  }

  @override
  Future internalChangeState(final LighthousePowerState newState) async {
    final characteristic = _characteristic;
    if (characteristic != null) {
      switch (newState) {
        case LighthousePowerState.on:
          await characteristic.write([0x01], withoutResponse: true);
          break;
        case LighthousePowerState.sleep:
          await characteristic.write([0x00], withoutResponse: true);
          break;
        case LighthousePowerState.standby:
          await characteristic.write([0x02], withoutResponse: true);
          break;
        case LighthousePowerState.booting:
        case LighthousePowerState.unknown:
          lighthouseLogger.warning("Cannot set power state to ${newState.text}",
              null, StackTrace.current);
          return;
      }
    }
  }

  /// Identify the current lighthouse by way of blinking the front LED.
  Future<void> identify() async {
    final identifyCharacteristic = _identifyCharacteristic;
    if (identifyCharacteristic == null) {
      lighthouseLogger.warning(
          "No identify characteristic set!", null, StackTrace.current);
      return;
    }
    final stack = StackTrace.current;
    await transactionMutex.protect(() async {
      // Write any byte to the characteristic to start the identify option.
      await identifyCharacteristic.write([0x00], withoutResponse: true);
    }, stack);
  }
}
