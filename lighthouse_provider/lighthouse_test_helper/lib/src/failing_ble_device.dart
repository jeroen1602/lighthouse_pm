// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:meta/meta.dart';

@visibleForTesting
class FailingBLEDeviceOnConnect extends FakeLighthouseV2Device {
  FailingBLEDeviceOnConnect() : super(1, 2);

  int disconnectCalls = 0;

  bool useTimeoutException = true;

  @override
  Future<void> connect({final Duration? timeout}) async {
    if (useTimeoutException) {
      throw TimeoutException(
          'Always failing ble faked a timeout exception', timeout);
    } else {
      throw StateError("Always failing ble faked a connection error");
    }
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }
}

@visibleForTesting
class FailingBLEDeviceOnDiscover extends FakeLighthouseV2Device {
  FailingBLEDeviceOnDiscover() : super(1, 2);

  int disconnectCalls = 0;

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    throw StateError("Failed on purpose because of a test device!");
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    throw StateError("Failed on purpose because of a test device!");
  }
}

@visibleForTesting
class FailingV2DeviceOnSpecificCharacteristics extends FakeLighthouseV2Device {
  FailingV2DeviceOnSpecificCharacteristics() : super(1, 2) {
    service.characteristics.clear();
    service.characteristics.addAll([
      FailingFakeFirmwareCharacteristic(),
      FailingFakeModelNumberCharacteristic(),
      FailingFakeSerialNumberCharacteristic(),
      FailingFakeHardwareRevisionCharacteristic(),
      FailingFakeManufacturerNameCharacteristic(),
      FailingFakeChannelCharacteristic(),
      ...FakeLighthouseV2Device.getPowerAndIdentifyCharacteristic(),
    ]);
  }
}

@visibleForTesting
class FailingFakeFirmwareCharacteristic extends FakeFirmwareCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class FailingFakeModelNumberCharacteristic
    extends FakeModelNumberCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class FailingFakeSerialNumberCharacteristic
    extends FakeSerialNumberCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class FailingFakeHardwareRevisionCharacteristic
    extends FakeHardwareRevisionCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class FailingFakeManufacturerNameCharacteristic
    extends FakeManufacturerNameCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class FailingFakeChannelCharacteristic extends FakeChannelCharacteristic {
  @override
  Future<List<int>> read() {
    throw StateError("Testing characteristic failing on purpose");
  }
}

@visibleForTesting
class CountingViveBaseStationDevice extends FakeViveBaseStationDevice {
  CountingViveBaseStationDevice() : super(4, 4);

  int disconnectCount = 0;

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    return super.disconnect();
  }
}

@visibleForTesting
class CountingFakeLighthouseV2Device extends FakeLighthouseV2Device {
  CountingFakeLighthouseV2Device() : super(4, 4);

  int disconnectCount = 0;

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    return super.disconnect();
  }
}

@visibleForTesting
class OfflineAbleLighthouseDevice extends FakeLighthouseV2Device {
  OfflineAbleLighthouseDevice(super.deviceName, super.deviceId);

  LHBluetoothDeviceState currentState = LHBluetoothDeviceState.connected;

  @override
  Stream<LHBluetoothDeviceState> get state => Stream.value(currentState);

  int disconnectCount = 0;

  @override
  Future<void> disconnect() async {
    disconnectCount++;
    return super.disconnect();
  }
}

@visibleForTesting
class ViveBaseStationWithIncorrectName extends FakeBluetoothDevice {
  ViveBaseStationWithIncorrectName()
      : super([
          FakeFirmwareCharacteristic(),
          FakeModelNumberCharacteristic(),
          FakeSerialNumberCharacteristic(),
          FakeHardwareRevisionCharacteristic(),
          FakeManufacturerNameCharacteristic(),
          FakeViveBaseStationCharacteristic()
        ], 0, "HTC BS 0000GH");
}

@visibleForTesting
class FailingViveBaseStationDeviceOnSpecificCharacteristics
    extends FakeLighthouseV2Device {
  FailingViveBaseStationDeviceOnSpecificCharacteristics() : super(1, 2) {
    service.characteristics.clear();
    service.characteristics.addAll([
      FailingFakeFirmwareCharacteristic(),
      FailingFakeModelNumberCharacteristic(),
      FailingFakeSerialNumberCharacteristic(),
      FailingFakeHardwareRevisionCharacteristic(),
      FailingFakeManufacturerNameCharacteristic(),
      FakeViveBaseStationCharacteristic(),
    ]);
  }
}
