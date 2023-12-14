part of '../../../vive_base_station_device_provider.dart';

class ViveBaseStationDevice extends BLEDevice<ViveBaseStationPersistence>
    implements DeviceWithExtensions {
  ViveBaseStationDevice(super.device, super.persistence,
      final RequestPairId<dynamic>? requestCallback)
      : _requestCallback = requestCallback;

  static const String powerServiceUUID = '0000cb00-0000-1000-8000-00805f9b34fb';
  static const String powerCharacteristicUUID =
      '0000cb01-0000-1000-8000-00805f9b34fb';

  @override
  final Set<DeviceExtension> deviceExtensions = {};
  LHBluetoothCharacteristic? _characteristic;
  int? _pairIdStorage;
  final RequestPairId<dynamic>? _requestCallback;

  int? get pairId => _pairIdStorage;

  set pairId(final int? id) {
    _pairIdStorage = id;
    _hasDeviceIdSubject.add(id != null);
    if (id == null) {
      _otherMetadata['Id'] = null;
    } else {
      _otherMetadata['Id'] =
          '0x${id.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }
  }

  @visibleForTesting
  int? pairIdEndHint;
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
  String get deviceType => "Vive base station";

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
  bool get hasOpenConnection {
    return _characteristic != null;
  }

  ///
  /// May throw [UnsupportedError] if state is something else than [LighthousePowerState.on] or [LighthousePowerState.standby].
  ///
  @override
  Future internalChangeState(final LighthousePowerState newState) async {
    final characteristic = _characteristic;
    if (characteristic == null) {
      return;
    }
    final id = pairId;
    assert(id != null);
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
    command.setUint32(4, id!, Endian.little);

    await characteristic.writeByteData(command, withoutResponse: true);
  }

  @override
  Future<bool> isValid() async {
    try {
      final subStringLocation = name.length - 4;
      pairIdEndHint = int.parse(name.substring(subStringLocation), radix: 16);
    } on FormatException catch (e, s) {
      lighthouseLogger.warning(
          "${device.name} ($deviceIdentifier): "
          "Could not get device id end",
          e,
          s);
    }
    if (persistence == null) {
      lighthouseLogger.warning("${device.name} ($deviceIdentifier): "
          "Persistence not set for ViveBaseStationDevice, "
          "will not be able to store the id");
    }
    pairId = await persistence?.getId(deviceIdentifier);
    if (pairId == null) {
      lighthouseLogger.warning("${device.name} ($deviceIdentifier): "
          "Pair id is not set yet");
    }
    lighthouseLogger
        .info("${device.name} ($deviceIdentifier): Connecting to device");
    try {
      await device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException catch (e, s) {
      lighthouseLogger.warning(
          "${device.name} ($deviceIdentifier): "
          "Connection timed-out",
          e,
          s);
      return false;
    } catch (e, s) {
      // other connection error
      lighthouseLogger.severe(
          "${device.name} ($deviceIdentifier): Unknown connection error", e, s);
      return false;
    }

    lighthouseLogger
        .info("${device.name} ($deviceIdentifier):  Finding services");
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
            lighthouseLogger.severe(
                "${device.name} ($deviceIdentifier): Unable to get firmware version",
                e,
                s);
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
    if (persistence != null) {
      deviceExtensions.add(ClearIdExtension(
          persistence: persistence!,
          deviceId: deviceIdentifier,
          clearId: () => pairId = null));
    }
    deviceExtensions.add(SleepExtension(
        changeState: changeState,
        powerStateStream: _getPowerStateStreamForExtensions));
    deviceExtensions.add(OnExtension(
        changeState: changeState,
        powerStateStream: _getPowerStateStreamForExtensions));
  }

  Stream<LighthousePowerState> _getPowerStateStreamForExtensions() {
    return _hasDeviceIdSubject.stream.map((final hasId) {
      if (hasId) {
        return LighthousePowerState.unknown;
      } else {
        return LighthousePowerState.booting;
      }
    }).asBroadcastStream();
  }

  @override
  Future<bool> requestExtraInfo<C>([final C? context]) async {
    if (pairId != null) {
      return true;
    }
    final callback = _requestCallback;
    if (callback == null) {
      assert(() {
        throw StateError(
            "${device.name} ($deviceIdentifier):  Request pair id has not been set on the vive provider");
      }());
      return false;
    }
    final deviceIdEnd = pairIdEndHint;
    String? value = (await callback(context, deviceIdEnd))?.toUpperCase();
    if (value == null) {
      return false;
    }
    if (value.length == 4 && deviceIdEnd != null) {
      value += deviceIdEnd.toRadixString(16).padLeft(4, '0').toUpperCase();
    }
    if (value.length == 8) {
      try {
        pairId = int.parse(value, radix: 16);
        final storage = persistence;
        if (storage != null) {
          await storage.insertId(deviceIdentifier, pairId!);
        } else {
          lighthouseLogger.warning(
              "${device.name} ($deviceIdentifier): Could not save device id because the storage was null");
        }
        return true;
      } on FormatException catch (e, s) {
        lighthouseLogger.warning(
            "${device.name} ($deviceIdentifier): Could not convert device id to a number",
            e,
            s);
      }
    }
    return false;
  }
}
