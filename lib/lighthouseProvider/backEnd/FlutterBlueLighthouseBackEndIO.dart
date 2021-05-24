import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import '../ble/DeviceIdentifier.dart';
import '../helpers/FlutterBlueExtensions.dart';
import 'BLELighthouseBackEnd.dart';
import 'flutterBlue/FlutterBlueBluetoothDevice.dart';

/// A back end that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackEnd? _instance;

  FlutterBlueLighthouseBackEnd._();

  static FlutterBlueLighthouseBackEnd get instance {
    if (_instance == null) {
      _instance = FlutterBlueLighthouseBackEnd._();
    }
    return _instance!;
  }

  // Some state variables.
  final Mutex _devicesMutex = Mutex();
  Set<LHDeviceIdentifier> _connectingDevices = Set();
  Set<LHDeviceIdentifier> _rejectedDevices = Set();

  BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  ///
  /// Start scanning for [LighthouseDevice]s using [BLEDeviceProvider]s.
  ///
  /// Will call the [FlutterBlue.startScan] function in the background.
  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _startListeningScanResults();
    try {
      await FlutterBlue.instance.startScan(
          scanMode: ScanMode.lowLatency,
          timeout: timeout,
          allowDuplicates: true);
    } catch (e, s) {
      if (e is PlatformException) {
        if (e.code == "bluetooth_unavailable") {
          debugPrint("Bluetooth not available on this device!");
          await this.cleanUp();
          return;
        }
      }
      debugPrint("Unhandled exception! $e");
      debugPrint("$s");
      throw e;
    }
  }

  @override
  Future<void> stopScan() async {
    this._scanResultSubscription?.pause();
    try {
      await FlutterBlue.instance.stopScan();
    } catch (e, s) {
      if (e is PlatformException) {
        if (e.code == "bluetooth_unavailable") {
          debugPrint("Handled bluetooth unavailable error on stop scan");
          return;
        }
      }
      debugPrint("Unhandled exception! $e");
      debugPrint("$s");
      throw e;
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

  Future<void> _startListeningScanResults() async {
    var scanResultSubscription = _scanResultSubscription;
    if (scanResultSubscription != null) {
      if (!scanResultSubscription.isPaused) {
        scanResultSubscription.pause();
      }
      await scanResultSubscription.cancel();
      _scanResultSubscription = null;
    }

    scanResultSubscription = FlutterBlue.instance.scanResults
        .map((scanResults) {
          //TODO: Maybe move this to be a bit more generic.
          // Filter out all devices that don't have a correct name.
          final List<ScanResult> output = <ScanResult>[];
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
            if (updateLastSeen?.call(deviceIdentifier) == true) {
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
                      'Found a non valid device! Device id: ${scanResult.device.id.toString()}');
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
    scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
    this._scanResultSubscription = scanResultSubscription;
  }

  @override
  Stream<bool> get isScanning => FlutterBlue.instance.isScanning;

  @override
  Stream<BluetoothAdapterState> get state =>
      FlutterBlue.instance.state.map((event) {
        switch (event) {
          case BluetoothState.unknown:
            return BluetoothAdapterState.unknown;
          case BluetoothState.unavailable:
            return BluetoothAdapterState.unavailable;
          case BluetoothState.unauthorized:
            return BluetoothAdapterState.unauthorized;
          case BluetoothState.turningOn:
            return BluetoothAdapterState.turningOn;
          case BluetoothState.on:
            return BluetoothAdapterState.on;
          case BluetoothState.turningOff:
            return BluetoothAdapterState.turningOff;
          case BluetoothState.off:
            return BluetoothAdapterState.off;
        }
      });
}
