library flutter_reactive_ble_back_end;

import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

part 'ble/flutter_reactive_ble_characteristic.dart';
part 'ble/flutter_reactive_ble_device.dart';
part 'ble/flutter_reactive_ble_service.dart';

class FlutterReactiveBleBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static FlutterReactiveBleBackEnd? _instance;

  FlutterReactiveBleBackEnd._();

  static FlutterReactiveBleBackEnd get instance {
    return _instance ??= FlutterReactiveBleBackEnd._();
  }

  static const Duration _minimumConnectDuration = Duration(seconds: 15);

  // Some state variables.
  final Mutex _devicesMutex = Mutex();
  final Set<LHDeviceIdentifier> _connectingDevices = {};
  final Set<LHDeviceIdentifier> _rejectedDevices = {};

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;
  Timer? _stopTimer;

  final BehaviorSubject<bool> _isScanningSubject =
      BehaviorSubject.seeded(false);

  final _flutterReactiveBle = FlutterReactiveBle();

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state =>
      _flutterReactiveBle.statusStream.map((final state) {
        switch (state) {
          case BleStatus.unknown:
            return BluetoothAdapterState.unknown;
          case BleStatus.unsupported:
            return BluetoothAdapterState.unavailable;
          case BleStatus.unauthorized:
            return BluetoothAdapterState.unauthorized;
          case BleStatus.poweredOff:
            return BluetoothAdapterState.off;
          case BleStatus.locationServicesDisabled:
            return BluetoothAdapterState.unauthorized;
          case BleStatus.ready:
            return BluetoothAdapterState.on;
        }
      });

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    _stopTimer?.cancel();
    try {
      final stream = _flutterReactiveBle.scanForDevices(
          withServices: [],
          scanMode: ScanMode.lowLatency,
          requireLocationServicesEnabled: false);
      _isScanningSubject.add(true);
      await _startListeningScanResults(stream);
      _stopTimer = Timer(timeout, () {
        stopScan();
      });
    } catch (e, s) {
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    }
  }

  @override
  Future<void> cleanUp() async {
    _foundDeviceSubject.add(null);
    _connectingDevices.clear();
    _rejectedDevices.clear();
    if (_devicesMutex.isLocked) {
      _devicesMutex.release();
    }
  }

  @override
  Future<void> stopScan() async {
    _scanResultSubscription?.cancel();
    _stopTimer?.cancel();
    _stopTimer = null;
    _isScanningSubject.add(false);
  }

  @override
  Stream<bool>? get isScanning => _isScanningSubject.stream;

  Future<void> _startListeningScanResults(
      final Stream<DiscoveredDevice> stream) async {
    var scanResultSubscription = _scanResultSubscription;
    if (scanResultSubscription != null) {
      if (!scanResultSubscription.isPaused) {
        scanResultSubscription.pause();
      }
      await scanResultSubscription.cancel();
      _scanResultSubscription = null;
    }

    scanResultSubscription = stream.where((final device) {
      for (final deviceProvider in providers) {
        if (deviceProvider.nameCheck(device.name)) {
          return true;
        }
      }
      return false;
    }).listen((final device) {
      final deviceIdentifier = LHDeviceIdentifier(device.id);

      if (_connectingDevices.contains(deviceIdentifier) ||
          _rejectedDevices.contains(deviceIdentifier)) {
        return;
      }

      // Update the last seen item.
      if (updateLastSeen?.call(deviceIdentifier) ?? false) {
        return;
      }

      // Possibly a new lighthouse, let's make sure it's valid.
      _devicesMutex.acquire().then((final _) async {
        _connectingDevices.add(deviceIdentifier);
        if (_devicesMutex.isLocked) {
          _devicesMutex.release();
        }

        final lighthouseDevice = await getLighthouseDevice(
            FlutterReactiveBleBluetoothDevice(device));

        try {
          await _devicesMutex.acquire();
          if (lighthouseDevice == null) {
            lighthouseLogger.warning(
                "Found a non valid device! Device id: "
                "${device.id}",
                null,
                StackTrace.current);
            _rejectedDevices.add(deviceIdentifier);
          } else {
            _foundDeviceSubject.add(lighthouseDevice);
          }
          _connectingDevices.remove(deviceIdentifier);
        } finally {
          if (_devicesMutex.isLocked) {
            _devicesMutex.release();
          }
        }
      });
    });

    // Clean-up for when the stream is canceled.
    scanResultSubscription.onDone(() {
      _scanResultSubscription = null;
    });
    _scanResultSubscription = scanResultSubscription;
  }
}
