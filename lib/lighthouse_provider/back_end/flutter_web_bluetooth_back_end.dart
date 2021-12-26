import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import '../adapter_state/adapter_state.dart';
import '../ble/guid.dart';
import '../lighthouse_device.dart';
import 'ble_lighthouse_back_end.dart';
import 'flutter_web_bluetooth/flutter_web_bluetooth_device.dart';
import 'pair_back_end.dart';

class FlutterWebBluetoothBackend extends BLELighthouseBackEnd with PairBackEnd {
  static FlutterWebBluetoothBackend? _instance;

  FlutterWebBluetoothBackend._();

  static FlutterWebBluetoothBackend get instance {
    return _instance ??= FlutterWebBluetoothBackend._();
  }

  final BehaviorSubject<bool> _isScanningSubject =
      BehaviorSubject.seeded(false);

  @override
  Stream<bool>? get isScanning => _isScanningSubject.stream;

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;
  final Mutex _pairedDevicesSetMutex = Mutex();
  final Set<BluetoothDevice> _pairedDevices = {};
  final BehaviorSubject<int> _numberOfPairedDevicesSubject =
      BehaviorSubject.seeded(0);

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state {
    if (!FlutterWebBluetooth.instance.isBluetoothApiSupported) {
      return Stream.value(BluetoothAdapterState.unavailable);
    }
    return FlutterWebBluetooth.instance.isAvailable.map((available) {
      return available
          ? BluetoothAdapterState.on
          : BluetoothAdapterState.unavailable;
    });
  }

  @override
  Future<void> stopScan() async {
    _isScanningSubject.add(false);
  }

  @override
  Future<void> cleanUp() async {
    _foundDeviceSubject.add(null);
  }

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _startListeningScanResult();
    await _pairedDevicesSetMutex.acquire();
    try {
      _isScanningSubject.add(true);
      for (final device in _pairedDevices) {
        final List<LighthouseGuid> characteristicsGuid =
            _getCharacteristicsForDevice(device.name ?? '');

        final lhDevice = await getLighthouseDevice(
            FlutterWebBluetoothDevice(device, characteristicsGuid));
        if (lhDevice != null) {
          _foundDeviceSubject.add(lhDevice);
        } else {
          debugPrint("Could not connected to an earlier paired device.");
        }
      }
    } finally {
      _pairedDevicesSetMutex.release();
      _isScanningSubject.add(false);
    }
  }

  Future<void> _startListeningScanResult() async {
    var scanResultSubscription = _scanResultSubscription;
    if (scanResultSubscription != null) {
      if (scanResultSubscription.isPaused) {
        await scanResultSubscription.cancel();
        _scanResultSubscription = null;
      }
    }

    scanResultSubscription =
        FlutterWebBluetooth.instance.devices.listen((devices) async {
      await _pairedDevicesSetMutex.acquire();
      try {
        _pairedDevices.clear();
        _pairedDevices.addAll(devices);
        _numberOfPairedDevicesSubject.add(_pairedDevices.length);
      } finally {
        _pairedDevicesSetMutex.release();
      }
    });

    scanResultSubscription.onDone(() {
      _scanResultSubscription = null;
    });
    _scanResultSubscription = scanResultSubscription;
  }

  RequestOptionsBuilder _createBuilder() {
    Set<LighthouseGuid> services = {};
    List<RequestFilterBuilder> requestFilters = [];
    for (final provider in providers) {
      services.addAll(provider.requiredServices);
      services.addAll(provider.optionalServices);
      requestFilters.add(RequestFilterBuilder(namePrefix: provider.namePrefix));
    }
    return RequestOptionsBuilder(requestFilters,
        optionalServices:
            services.map((e) => e.toString().toLowerCase()).toList());
  }

  List<LighthouseGuid> _getCharacteristicsForDevice(String deviceName) {
    List<LighthouseGuid> characteristicsGuid = [];
    for (final provider in providers) {
      if (provider.nameCheck(deviceName)) {
        characteristicsGuid.addAll(provider.characteristics);
      }
    }
    return characteristicsGuid;
  }

  @override
  Future<void> pairNewDevice(
      {required Duration timeout, required Duration? updateInterval}) async {
    this.updateInterval = updateInterval;
    await _startListeningScanResult();
    try {
      final requestOptions = _createBuilder();
      final device =
          await FlutterWebBluetooth.instance.requestDevice(requestOptions);

      final List<LighthouseGuid> characteristicsGuid =
          _getCharacteristicsForDevice(device.name ?? '');

      final lhDevice = await getLighthouseDevice(
          FlutterWebBluetoothDevice(device, characteristicsGuid));
      if (lhDevice != null) {
        _foundDeviceSubject.add(lhDevice);
      } else {
        debugPrint(
            "User selected non valid device. Maybe we should restrict the options more");
      }
    } on DeviceNotFoundError {
      // well what now?
      debugPrint('No devices found!');
    }
  }

  @override
  Stream<int> numberOfPairedDevices() => _numberOfPairedDevicesSubject.stream;
}
