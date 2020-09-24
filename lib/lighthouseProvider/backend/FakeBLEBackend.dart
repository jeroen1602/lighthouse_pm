import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/lighthouseProvider/backend/fake/FakeBluetoothDevice.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import 'BLELighthouseBackend.dart';

class FakeBLEBackend extends BLELighthouseBackend {
// Make sure there is always only one instance.
  static FakeBLEBackend /* ? */ _instance;

  FakeBLEBackend._();

  static FakeBLEBackend get instance {
    if (_instance == null) {
      _instance = FakeBLEBackend._();
    }
    return _instance;
  }

  final random = Random();

  BehaviorSubject<LighthouseDevice /* ? */ > _foundDeviceSubject =
      BehaviorSubject.seeded(null);

  @override
  Stream<LighthouseDevice> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Future<void> stopScan() async {
    _foundDeviceSubject.add(null);
    //NAH
  }

  @override
  Future<void> startScan({@required Duration timeout}) async {
    await super.startScan(timeout: timeout);
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
  }

  @override
  Future<void> cleanUp() async {}
}
