part of '../../fake_back_end.dart';

class FakeBluetoothDevice extends LHBluetoothDevice {
  final LHDeviceIdentifier deviceIdentifier;
  final SimpleBluetoothService service;
  final String _name;

  FakeBluetoothDevice(final List<LHBluetoothCharacteristic> characteristics,
      final int id, final String name)
      : service = SimpleBluetoothService(characteristics),
        deviceIdentifier = _generateIdentifier(id),
        _name = name;

  static LHDeviceIdentifier _generateIdentifier(final int id) {
    if (SharedPlatform.isWeb) {
      return LHDeviceIdentifier(
          'a${FakeDeviceIdentifier.generateDeviceIdentifier(id).toString().substring(1)}');
    }
    return FakeDeviceIdentifier.generateDeviceIdentifier(id);
  }

  @override
  Future<void> connect({final Duration? timeout}) async {
    // do nothing
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    return [service];
  }

  @override
  LHDeviceIdentifier get id => deviceIdentifier;

  @override
  String get name => _name;

  @override
  Stream<LHBluetoothDeviceState> get state =>
      Stream.value(LHBluetoothDeviceState.connected);
}

class FakeLighthouseV2Device extends FakeBluetoothDevice {
  FakeLighthouseV2Device(final int deviceName, final int deviceId)
      : super([
          FakeFirmwareCharacteristic(),
          FakeModelNumberCharacteristic(),
          FakeSerialNumberCharacteristic(),
          FakeHardwareRevisionCharacteristic(),
          FakeManufacturerNameCharacteristic(),
          FakeChannelCharacteristic(),
          ...getPowerAndIdentifyCharacteristic(),
        ], deviceId, _getNameFromInt(deviceName));

  static String _getNameFromInt(final int deviceName) {
    return 'LHB-000000${deviceName.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  @visibleForTesting
  static List<FakeReadWriteCharacteristic> getPowerAndIdentifyCharacteristic() {
    final powerCharacteristic = FakeLighthouseV2PowerCharacteristic();
    return [
      powerCharacteristic,
      FakeLighthouseV2IdentifyCharacteristic(powerCharacteristic)
    ];
  }
}

class FakeViveBaseStationDevice extends FakeBluetoothDevice {
  FakeViveBaseStationDevice(final int deviceName, final int deviceId)
      : super([
          FakeFirmwareCharacteristic(),
          FakeModelNumberCharacteristic(),
          FakeSerialNumberCharacteristic(),
          FakeHardwareRevisionCharacteristic(),
          FakeManufacturerNameCharacteristic(),
          FakeViveBaseStationCharacteristic()
        ], deviceId, _getNameFromInt(deviceName));

  static String _getNameFromInt(final int deviceName) {
    return 'HTC BS 0000${deviceName.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
}

@visibleForTesting
class SimpleBluetoothService extends LHBluetoothService {
  SimpleBluetoothService(final List<LHBluetoothCharacteristic> characteristics)
      : _characteristics = characteristics;

  final List<LHBluetoothCharacteristic> _characteristics;

  final LighthouseGuid _uuid =
      LighthouseGuid.fromString('00000000-0000-0000-0000-000000000001');

  @override
  List<LHBluetoothCharacteristic> get characteristics => _characteristics;

  @override
  LighthouseGuid get uuid => _uuid;
}

abstract class FakeReadWriteCharacteristic extends LHBluetoothCharacteristic {
  final LighthouseGuid _uuid;

  List<int> data = [];

  FakeReadWriteCharacteristic(final LighthouseGuid uuid) : _uuid = uuid;

  @override
  LighthouseGuid get uuid => _uuid;

  @override
  Future<List<int>> read() async {
    return data;
  }
}

abstract class FakeReadOnlyCharacteristic extends LHBluetoothCharacteristic {
  final List<int> data;
  final LighthouseGuid _uuid;

  FakeReadOnlyCharacteristic(this.data, final LighthouseGuid uuid)
      : _uuid = uuid;

  @override
  LighthouseGuid get uuid => _uuid;

  @override
  Future<List<int>> read() async => data;

  @override
  Future<Function> write(final List<int> data,
      {final bool withoutResponse = false}) {
    throw UnimplementedError(
        'Write is not supported by FakeReadOnlyCharacteristic');
  }
}

//region Fake default
@visibleForTesting
class FakeFirmwareCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeFirmwareCharacteristic()
      : super(
            intListFromString('FAKE_DEVICE'),
            LighthouseGuid.fromString(BluetoothDefaultCharacteristicUUIDS
                .firmwareRevisionString.uuid));
}

@visibleForTesting
class FakeModelNumberCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeModelNumberCharacteristic()
      : super(
            intListFromNumber(0xFF),
            LighthouseGuid.fromString(
                BluetoothDefaultCharacteristicUUIDS.modelNumberString.uuid));
}

@visibleForTesting
class FakeSerialNumberCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeSerialNumberCharacteristic()
      : super(
            intListFromNumber(0xFF),
            LighthouseGuid.fromString(
                BluetoothDefaultCharacteristicUUIDS.serialNumberString.uuid));
}

@visibleForTesting
class FakeHardwareRevisionCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeHardwareRevisionCharacteristic()
      : super(
            intListFromString('FAKE_REVISION'),
            LighthouseGuid.fromString(BluetoothDefaultCharacteristicUUIDS
                .hardwareRevisionString.uuid));
}

@visibleForTesting
class FakeManufacturerNameCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeManufacturerNameCharacteristic()
      : super(
            intListFromString('LIGHTHOUSE PM By Jeroen1602'),
            LighthouseGuid.fromString(BluetoothDefaultCharacteristicUUIDS
                .manufacturerNameString.uuid));
}
//endregion

@visibleForTesting
class FakeChannelCharacteristic extends FakeReadOnlyCharacteristic {
  @visibleForTesting
  FakeChannelCharacteristic()
      : super(
            intListFromNumber(0xFF),
            LighthouseGuid.fromString(
                LighthouseV2Device.channelCharacteristicUUID));
}

@visibleForTesting
class FakeLighthouseV2PowerCharacteristic extends FakeReadWriteCharacteristic {
  @visibleForTesting
  FakeLighthouseV2PowerCharacteristic()
      : super(LighthouseGuid.fromString(
            LighthouseV2Device.powerCharacteristicUUID)) {
    if (random.nextBool()) {
      data.add(0x00); // sleep
    } else {
      data.add(0x0b); // on
    }
  }

  final random = Random();

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    if (data.length != 1) {
      lighthouseLogger.warning("Send incorrect amount of bytes to fake "
          "lighthouse v2 power characteristic");
      return;
    }
    final byte = data[0];
    switch (byte) {
      case 0x00:
        this.data[0] = byte;
        break;
      case 0x01:
      case 0x02:
        // Go from on to standby
        if (this.data[0] == 0x0b && byte == 0x02) {
          this.data[0] = byte;
          break;
        }
        // Go from standby to on
        if (this.data[0] == 0x02 && byte == 0x01) {
          this.data[0] = 0x0b;
          break;
        }
        // Go from off to standby/ on.
        this.data[0] = byte;
        Future.delayed(Duration(milliseconds: 10)).then((final value) async {
          // booting
          this.data[0] = 0x09;
          await Future.delayed(Duration(milliseconds: 1200));
        }).then((final value) {
          if (byte == 0x01) {
            this.data[0] = 0x0b; // on
          } else {
            this.data[0] = byte; // other
          }
        });

        break;
      default:
        lighthouseLogger.warning(
            "Unknown state 0x${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}",
            null,
            StackTrace.current);
    }
  }
}

@visibleForTesting
class FakeLighthouseV2IdentifyCharacteristic
    extends FakeReadWriteCharacteristic {
  @visibleForTesting
  FakeLighthouseV2IdentifyCharacteristic(this.powerCharacteristic)
      : super(
          LighthouseGuid.fromString(
              LighthouseV2Device.identifyCharacteristicUUID),
        );

  final FakeLighthouseV2PowerCharacteristic powerCharacteristic;

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    if (data.length == 1 && data[0] == 0x00) {
      await powerCharacteristic.write([0x01], withoutResponse: withoutResponse);
    } else {
      lighthouseLogger.warning(
          "Send unrecognized data to the identify characteristic",
          null,
          StackTrace.current);
    }
  }
}

@visibleForTesting
class FakeViveBaseStationCharacteristic extends FakeReadWriteCharacteristic {
  @visibleForTesting
  FakeViveBaseStationCharacteristic()
      : super(LighthouseGuid.fromString(
            ViveBaseStationDevice.powerCharacteristicUUID)) {
    data.addAll([0x00, 0x12]);
  }

  void changeState(final LighthousePowerState state) {
    switch (state) {
      case LighthousePowerState.on:
        data.clear();
        data.addAll([0x00, 0x15]);
        break;
      case LighthousePowerState.sleep:
        data.clear();
        data.addAll([0x00, 0x12]);
        break;
      default:
        lighthouseLogger.warning(
            "Could not handle state: ${state.text}", null, StackTrace.current);
    }
  }

  @override
  Future<void> write(final List<int> data,
      {final bool withoutResponse = false}) async {
    if (data.length < 4) {
      lighthouseLogger.warning(
          "Incorrect command send to FakeViveBaseStationCharacteristic",
          null,
          StackTrace.current);
      return;
    }
    if (data[1] == 0x00 && data[2] == 0x00 && data[3] == 0x00) {
      changeState(LighthousePowerState.on);
    } else if (data[1] == 0x02 && data[2] == 0x00 && data[3] == 0x01) {
      changeState(LighthousePowerState.sleep);
    } else {
      lighthouseLogger.warning(
          "Incorrect command send to FakeViveBaseStationCharacteristic",
          null,
          StackTrace.current);
      return;
    }
  }
}

@visibleForTesting
List<int> intListFromString(final String data) {
  return Utf8Encoder().convert(data).toList();
}

///
/// Converts a number to an int list. Will also trim the leading 00's from the
/// number. On io platforms it will work with a max of 64bit ints, for web it
/// will work with a max of 32bit ints.
///
/// If the input number is 0xFF00, then the output will be [0xFF, 0x00]. Where
/// the leading 0x00's have been stripped from the conversion.
///
/// If the input is 0x00, then the output will be [] (empty list).
///
@visibleForTesting
List<int> intListFromNumber(final int number) {
  final data = ByteData(SharedPlatform.isWeb ? 4 : 8);
  if (SharedPlatform.isWeb) {
    data.setUint32(0, number, Endian.big);
  } else {
    data.setUint64(0, number, Endian.big);
  }
  final List<int> list = List<int>.filled(data.lengthInBytes, 0);
  var nonZero = false;
  var trimZeroStart = -1;
  //        V
  // 00 00 00 FF
  for (int i = 0; i < data.lengthInBytes; i++) {
    final byte = data.getUint8(i);
    if (byte > 0 && !nonZero) {
      nonZero = true;
      trimZeroStart = i - 1;
    }
    list[i] = byte;
  }
  if (nonZero) {
    if (trimZeroStart > 0) {
      // 00 00 00 FF -> FF
      // 00 00 FF 00 -> FF 00
      return list.sublist(trimZeroStart);
    }
    return list;
  } else {
    return <int>[];
  }
}
