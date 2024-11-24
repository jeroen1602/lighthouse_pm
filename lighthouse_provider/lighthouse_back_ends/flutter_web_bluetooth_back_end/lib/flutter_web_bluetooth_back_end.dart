library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/js_web_bluetooth.dart';
import 'package:flutter_web_bluetooth/web_bluetooth_logger.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

part 'src/ble/flutter_web_bluetooth_characteristic.dart';

part 'src/ble/flutter_web_bluetooth_device.dart';

part 'src/ble/flutter_web_bluetooth_service.dart';

class FlutterWebBluetoothBackEnd extends BLELighthouseBackEnd with PairBackEnd {
  static FlutterWebBluetoothBackEnd? _instance;

  FlutterWebBluetoothBackEnd._() {
    setWebBluetoothLogger(lighthouseLogger);
  }

  static FlutterWebBluetoothBackEnd get instance {
    return _instance ??= FlutterWebBluetoothBackEnd._();
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
    return FlutterWebBluetooth.instance.isAvailable.map((final available) {
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
  Future<void> cleanUp({final bool onlyDisconnected = false}) async {
    _foundDeviceSubject.add(null);
  }

  @override
  Future<void> startScan(
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
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
          lighthouseLogger
              .info("Could not connect to an earlier paired device.");
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
        FlutterWebBluetooth.instance.devices.listen((final devices) async {
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
    final Set<LighthouseGuid> services = {};
    final List<RequestFilterBuilder> requestFilters = [];
    for (final provider in providers) {
      services.addAll(provider.requiredServices);
      services.addAll(provider.optionalServices);
      requestFilters.add(RequestFilterBuilder(namePrefix: provider.namePrefix));
    }
    return RequestOptionsBuilder(requestFilters,
        optionalServices:
            services.map((final e) => e.toString().toLowerCase()).toList());
  }

  List<LighthouseGuid> _getCharacteristicsForDevice(final String deviceName) {
    final List<LighthouseGuid> characteristicsGuid = [];
    for (final provider in providers) {
      if (provider.nameCheck(deviceName)) {
        characteristicsGuid.addAll(provider.characteristics);
      }
    }
    return characteristicsGuid;
  }

  @override
  Future<void> pairNewDevice(
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
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
        lighthouseLogger.warning("user selected a non valid device. "
            "Maybe the settings should be restricted more.");
        if (device.hasForget) {
          lighthouseLogger
              .info("The device supports forget, so it will be forgotten.");
          device.forget();
        }
      }
    } on DeviceNotFoundError {
      // well what now?
      lighthouseLogger.warning("No device found!");
    }
  }

  @override
  Stream<int> numberOfPairedDevices() => _numberOfPairedDevicesSubject.stream;

  @override
  String get backendName => "FlutterWebBluetoothBackEnd";
}
