library fake_back_end;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';
import 'package:shared_platform/shared_platform.dart';
import 'package:rxdart/rxdart.dart';

part 'src/ble/fake_bluetooth_device.dart';

part 'src/ble/fake_device_identifier.dart';

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
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
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
