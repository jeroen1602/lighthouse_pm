import 'dart:math';

import 'package:rxdart/rxdart.dart';

import '../adapter_state/adapter_state.dart';
import '../lighthouse_device.dart';
import 'ble_lighthouse_back_end.dart';
import 'fake/fake_bluetooth_device.dart';

class FakeBLEBackEnd extends BLELighthouseBackEnd {
// Make sure there is always only one instance.
  static FakeBLEBackEnd? _instance;

  FakeBLEBackEnd._();

  static FakeBLEBackEnd get instance {
    return _instance ??= FakeBLEBackEnd._();
  }

  final random = Random();

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Future<void> stopScan() async {
    _foundDeviceSubject.add(null);
    _isScanningSubject.add(false);
  }

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    _isScanningSubject.add(true);
    for (int i = 0; i < 2; i++) {
      await Future.delayed(Duration(milliseconds: random.nextInt(500) + 200));
      final device = await getLighthouseDevice(FakeLighthouseV2Device(i, i));
      if (device != null) {
        _foundDeviceSubject.add(device);
      }
    }
    for (int i = 2; i < 4; i++) {
      await Future.delayed(Duration(milliseconds: random.nextInt(500) + 200));
      final device =
          await getLighthouseDevice(FakeViveBaseStationDevice(i - 2, i));
      if (device != null) {
        _foundDeviceSubject.add(device);
      }
    }
    _isScanningSubject.add(false);
  }

  final BehaviorSubject<bool> _isScanningSubject =
      BehaviorSubject.seeded(false);

  @override
  Stream<bool> get isScanning => _isScanningSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state =>
      Stream.value(BluetoothAdapterState.on);
}
