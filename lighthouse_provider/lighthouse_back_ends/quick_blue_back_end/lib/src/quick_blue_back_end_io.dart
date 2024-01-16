library quick_blue_back_end;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:rxdart/rxdart.dart';

part 'ble/quick_blue_characteristic.dart';
part 'ble/quick_blue_device.dart';
part 'ble/quick_blue_service.dart';
part 'helper/connection_handler.dart';
part 'helper/service_handler.dart';
part 'helper/value_handler.dart';

class QuickBlueBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static QuickBlueBackEnd? _instance;

  QuickBlueBackEnd._();

  static QuickBlueBackEnd get instance {
    return _instance ??= QuickBlueBackEnd._();
  }

  // Some state variables.
  final Mutex _devicesMutex = Mutex();
  final Set<LHDeviceIdentifier> _connectingDevices = {};
  final Set<LHDeviceIdentifier> _rejectedDevices = {};

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;
  Timer? _stopTimer;

  final ConnectionHandler _connectionHandler = ConnectionHandler._();
  final ServiceHandler _serviceHandler = ServiceHandler._();
  final ValueHandler _valueHandler = ValueHandler._();

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state async* {
    while (true) {
      yield await QuickBlue.isBluetoothAvailable().then((final value) {
        if (value) {
          return BluetoothAdapterState.on;
        } else {
          return BluetoothAdapterState.unavailable;
        }
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    _stopTimer?.cancel();
    await _startListeningScanResults();
    try {
      QuickBlue.startScan();
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
    await Future.wait([
      _connectionHandler.removeAllSubjects(),
      _serviceHandler.removeAllSubjects(),
      _valueHandler.removeAllReadCompleter(),
    ]);
  }

  @override
  Future<void> stopScan() async {
    _scanResultSubscription?.pause();
    _stopTimer?.cancel();
    _stopTimer = null;
    try {
      QuickBlue.stopScan();
    } catch (e, s) {
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    }
  }

  Future<void> _startListeningScanResults() async {
    var scanResultSubscription = _scanResultSubscription;
    if (scanResultSubscription != null) {
      if (!scanResultSubscription.isPaused) {
        scanResultSubscription.pause();
      }
      await scanResultSubscription.cancel();
      _scanResultSubscription = null;
    }

    scanResultSubscription = QuickBlue.scanResultStream.where((final device) {
      for (final deviceProvider in providers) {
        if (deviceProvider.nameCheck(device.name)) {
          return true;
        }
      }
      return false;
    }).listen((final device) {
      final deviceIdentifier = LHDeviceIdentifier(device.deviceId);

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
            FlutterReactiveBleBluetoothDevice(
                device, _connectionHandler, _serviceHandler, _valueHandler));

        try {
          await _devicesMutex.acquire();
          if (lighthouseDevice == null) {
            lighthouseLogger.warning(
                "Found a non valid device! Device id: "
                "${device.deviceId}",
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
