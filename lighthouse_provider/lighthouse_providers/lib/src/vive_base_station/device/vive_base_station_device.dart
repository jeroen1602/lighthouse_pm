part of vive_base_station_device_provider;

class ViveBaseStationDevice extends BLEDevice<ViveBaseStationPersistence>
    implements DeviceWithExtensions {
  ViveBaseStationDevice(
      final LHBluetoothDevice device,
      final ViveBaseStationPersistence? persistence,
      final RequestPairId<dynamic>? requestCallback)
      : _requestCallback = requestCallback,
        super(device, persistence);

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
  LighthousePowerState powerStateFromByte(final int byte) {
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
      pairIdEndHint = int.parse(name.substring(subStringLocation), radix: 16);
    } on FormatException catch (e, s) {
      lighthouseLogger.warning(
          "Could not get device id end from name \"$name\"", e, s);
    }
    if (persistence == null) {
      lighthouseLogger.warning("Persistence not set for ViveBaseStationDevice, "
          "will not be able to store the id");
    }
    pairId = await persistence?.getId(deviceIdentifier);
    if (pairId == null) {
      lighthouseLogger.warning("Pair di is not set yet for \"$name\"");
    }
    lighthouseLogger.info("Connecting to device: $deviceIdentifier");
    try {
      await device.connect(timeout: Duration(seconds: 10));
    } on TimeoutException catch (e, s) {
      lighthouseLogger.warning(
          "Connection timed-out for device: $deviceIdentifier", e, s);
      return false;
    } catch (e, s) {
      // other connection error
      lighthouseLogger.severe("Unknown connection error", e, s);
      return false;
    }

    lighthouseLogger.info("Finding services for device: $deviceIdentifier");
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
            lighthouseLogger.severe("Unable to get firmware version", e, s);
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
    LighthousePowerState lastState = LighthousePowerState.unknown;
    bool hasId = false;
    return MergeStream<dynamic>([powerStateEnum, _hasDeviceIdSubject.stream])
        .map((final event) {
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
  Future<bool> requestExtraInfo<C>([final C? context]) async {
    if (pairId != null) {
      return true;
    }
    final callback = _requestCallback;
    if (callback == null) {
      assert(() {
        throw StateError(
            "Request pair id has not been set on the vive provider");
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
          lighthouseLogger
              .warning("Could not save device id because the storage was null");
        }
        return true;
      } on FormatException catch (e, s) {
        lighthouseLogger.warning(
            "Could not convert device id to a number", e, s);
      }
    }
    return false;
  }
}
