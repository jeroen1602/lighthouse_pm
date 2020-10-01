import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import '../ble/DeviceIdentifier.dart';
import '../helpers/FlutterBlueExtensions.dart';
import 'BLELighthouseBackEnd.dart';
import 'flutterBlue/FlutterBlueBluetoothDevice.dart';

/// A back end that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackEnd /* ? */ _instance;

  FlutterBlueLighthouseBackEnd._();

  static FlutterBlueLighthouseBackEnd get instance {
    if (_instance == null) {
      _instance = FlutterBlueLighthouseBackEnd._();
    }
    return _instance;
  }

  // Some state variables.
  final Mutex _devicesMutex = Mutex();
  Set<LHDeviceIdentifier> _connectingDevices = Set();
  Set<LHDeviceIdentifier> _rejectedDevices = Set();

  BehaviorSubject<LighthouseDevice /* ? */ > _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription /* ? */ _scanResultSubscription;

  @override
  Stream<LighthouseDevice /* ? */ > get lighthouseStream =>
      _foundDeviceSubject.stream;

  ///
  /// Start scanning for [LighthouseDevice]s using [BLEDeviceProvider]s.
  ///
  /// Will call the [FlutterBlue.startScan] function in the background.
  @override
  Future<void> startScan({@required Duration timeout}) async {
    await super.startScan(timeout: timeout);
    await _startListeningScanResults();
    await FlutterBlue.instance.startScan(
        scanMode: ScanMode.lowLatency, timeout: timeout, allowDuplicates: true);
  }

  @override
  Future<void> stopScan() async {
    if (this._scanResultSubscription != null) {
      this._scanResultSubscription.pause();
    }
    await FlutterBlue.instance.stopScan();
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

  Future<void> _startListeningScanResults() async {
    if (_scanResultSubscription != null) {
      if (!_scanResultSubscription.isPaused) {
        _scanResultSubscription.pause();
      }
      await _scanResultSubscription.cancel();
      _scanResultSubscription = null;
    }

    _scanResultSubscription = FlutterBlue.instance.scanResults
        .map((scanResults) {
          //TODO: Maybe move this to be a bit more generic.
          // Filter out all devices that don't have a correct name.
          final List<ScanResult> output = List();
          for (final scanResult in scanResults) {
            for (final deviceProvider in providers) {
              if (deviceProvider.nameCheck(scanResult.device.name)) {
                output.add(scanResult);
                break;
              }
            }
          }
          return output;
        })
        // Give the listener at least 2ms to process the data before firing again.
        .debounce((_) => TimerStream(true, Duration(milliseconds: 2)))
        .listen((scanResults) {
          if (scanResults.isEmpty) {
            return;
          }
          for (final scanResult in scanResults) {
            final deviceIdentifier =
                scanResult.device.id.toLHDeviceIdentifier();

            if (this._connectingDevices.contains(deviceIdentifier)) {
              continue;
            }
            if (this._rejectedDevices.contains(deviceIdentifier)) {
              continue;
            }
            // Update the last seen item.
            if (updateLastSeen(deviceIdentifier)) {
              continue;
            }
            // Possibly a new lighthouse, let's make sure it's valid.
            this._devicesMutex.acquire().then((_) async {
              this._connectingDevices.add(deviceIdentifier);
              if (_devicesMutex.isLocked) {
                _devicesMutex.release();
              }

              final lighthouseDevice = await getLighthouseDevice(
                  FlutterBlueBluetoothDevice(scanResult.device));
              try {
                await _devicesMutex.acquire();
                if (lighthouseDevice == null) {
                  debugPrint(
                      'Found a non valid device! Mac: ${scanResult.device.id.toString()}');
                  this._rejectedDevices.add(deviceIdentifier);
                } else {
                  this._foundDeviceSubject.add(lighthouseDevice);
                }
                this._connectingDevices.remove(deviceIdentifier);
              } finally {
                if (_devicesMutex.isLocked) {
                  _devicesMutex.release();
                }
              }
            });
          }
        });
    // Clean-up for when the stream is canceled.
    _scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
  }

  @override
  Stream<bool> get isScanning => FlutterBlue.instance.isScanning;
}
