import 'dart:async';

import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:meta/meta.dart';

@visibleForTesting
class FakeHighLevelDevice extends BLEDevice implements DeviceWithExtensions {
  FakeHighLevelDevice(final LHBluetoothDevice device) : super(device, null);

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
  Future internalChangeState(final LighthousePowerState newState) async {
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
  LighthousePowerState powerStateFromByte(final int byte) {
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
    return services.isNotEmpty;
  }

  Set<DeviceExtension> extensions = {};

  @override
  Set<DeviceExtension> get deviceExtensions => extensions;
}
