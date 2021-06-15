import 'dart:async';

import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';

class FakeHighLevelDevice extends BLEDevice {
  FakeHighLevelDevice(LHBluetoothDevice device) : super(device);

  @override
  void afterIsValid() {}

  @override
  Future cleanupConnection() async {}

  @override
  String get firmwareVersion => throw UnimplementedError();

  @override
  Future<int?> getCurrentState() {
    throw UnimplementedError();
  }

  @override
  bool get hasOpenConnection => throw UnimplementedError();

  int changeStateCalled = 0;
  bool errorOnInternalChangeState =false;

  @override
  Future internalChangeState(LighthousePowerState newState) async {
    changeStateCalled++;
    if (errorOnInternalChangeState) {
      throw StateError("Test error for internal change state");
    }
    // TODO: change state.
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
}
