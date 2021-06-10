import 'dart:async';

import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothService.dart';

class FailingBLEDeviceOnConnect extends FakeLighthouseV2Device {
  FailingBLEDeviceOnConnect() : super(1, 2);

  int disconnectCalls = 0;

  @override
  Future<void> connect({Duration? timeout}) async {
    throw TimeoutException(
        'Always failing ble faked a timeout exception', timeout);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }
}

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
