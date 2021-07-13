import 'dart:async';

import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/fake/FakeBluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceExtension.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceWithExtensions.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';

class FakeHighLevelDevice extends BLEDevice implements DeviceWithExtensions {
  FakeHighLevelDevice(LHBluetoothDevice device) : super(device);

  FakeHighLevelDevice.simple() : this(FakeLighthouseV2Device(1, 1));

  @override
  void afterIsValid() {}

  @override
  Future cleanupConnection() async {}

  @override
  String get firmwareVersion => "WOW firmware";

  @override
  Future<int?> getCurrentState() {
    throw UnimplementedError();
  }

  bool openConnection = false;

  @override
  bool get hasOpenConnection => openConnection;

  int changeStateCalled = 0;
  bool errorOnInternalChangeState = false;

  @override
  Future internalChangeState(LighthousePowerState newState) async {
    changeStateCalled++;
    if (errorOnInternalChangeState) {
      throw StateError("Test error for internal change state");
    }
    // TODO: change state.
  }

  int disconnectCalled = 0;

  @override
  Future<void> disconnect() {
    disconnectCalled++;
    return super.disconnect();
  }

  @override
  String get name => device.name;

  @override
  Map<String, String?> get otherMetadata => throw UnimplementedError();

  @override
  LighthousePowerState powerStateFromByte(int byte) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isValid() async {
    try {
      await device.connect(timeout: Duration(milliseconds: 10));
    } on TimeoutException {
      return false;
    }

    final services = await device.discoverServices();
    return services.length > 0;
  }

  Set<DeviceExtension> extensions = Set();

  @override
  Set<DeviceExtension> get deviceExtensions => extensions;
}
