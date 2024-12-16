library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_platform/shared_platform.dart';

part 'ble/flutter_blue_plus_bluetooth_characteristic.dart';

part 'ble/flutter_blue_plus_bluetooth_device.dart';

part 'ble/flutter_blue_plus_bluetooth_service.dart';

part 'helpers/flutter_blue_plus_extensions.dart';

/// A back end that provides devices using [blue_plus.FlutterBluePlus].
class FlutterBluePlusLighthouseBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static FlutterBluePlusLighthouseBackEnd? _instance;

  FlutterBluePlusLighthouseBackEnd._();

  static FlutterBluePlusLighthouseBackEnd get instance {
    return _instance ??= FlutterBluePlusLighthouseBackEnd._();
  }

  // Some state variables.
  final Mutex _devicesMutex = Mutex();
  final Set<LHDeviceIdentifier> _connectingDevices = {};
  final Set<LHDeviceIdentifier> _rejectedDevices = {};

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  ///
  /// Start scanning for [LighthouseDevice]s using [BLEDeviceProvider]s.
  ///
  /// Will call the [blue_plus.FlutterBluePlus.startScan] function in the background.
  @override
  Future<void> startScan(
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _startListeningScanResults();
    try {
      await blue_plus.FlutterBluePlus.startScan(
        androidScanMode: blue_plus.AndroidScanMode.lowLatency,
        timeout: timeout,
        oneByOne: false,
        withKeywords:
            providers.map((final e) => e.namePrefix).toList(growable: false),
      );
    } on PlatformException catch (e, s) {
      if (e.code == "bluetooth_unavailable") {
        lighthouseLogger.info(
            "Bluetooth is not available on this device", e, s);
        await cleanUp();
        return;
      }
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    } catch (e, s) {
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    }
  }

  @override
  Future<void> stopScan() async {
    _scanResultSubscription?.pause();
    try {
      await blue_plus.FlutterBluePlus.stopScan();
    } on PlatformException catch (e, s) {
      if (e.code == "bluetooth_unavailable") {
        lighthouseLogger.info(
            "Handled bluetooth unavailable error on stop scan", e, s);
        return;
      }
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    } catch (e, s) {
      lighthouseLogger.severe("Unhandled exception", e, s);
      rethrow;
    }
  }

  @override
  Future<void> cleanUp({final bool onlyDisconnected = false}) async {
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

    scanResultSubscription = blue_plus.FlutterBluePlus.scanResults
        .map((final scanResults) {
          //TODO: Maybe move this to be a bit more generic.
          // Filter out all devices that don't have a correct name.
          final List<blue_plus.ScanResult> output = <blue_plus.ScanResult>[];
          for (final scanResult in scanResults) {
            for (final deviceProvider in providers) {
              if (deviceProvider.nameCheck(scanResult.device.platformName)) {
                output.add(scanResult);
                break;
              }
            }
          }
          return output;
        })
        // Give the listener at least 2ms to process the data before firing again.
        .debounceTime(const Duration(milliseconds: 2))
        .listen((final scanResults) {
          if (scanResults.isEmpty) {
            return;
          }
          for (final scanResult in scanResults) {
            final deviceIdentifier =
                scanResult.device.remoteId.toLHDeviceIdentifier();

            if (_connectingDevices.contains(deviceIdentifier)) {
              continue;
            }
            if (_rejectedDevices.contains(deviceIdentifier)) {
              continue;
            }
            // Update the last seen item.
            if (updateLastSeen?.call(deviceIdentifier) ?? false) {
              continue;
            }
            // Possibly a new lighthouse, let's make sure it's valid.
            _devicesMutex.acquire().then((final _) async {
              _connectingDevices.add(deviceIdentifier);
              if (_devicesMutex.isLocked) {
                _devicesMutex.release();
              }

              final lighthouseDevice = await getLighthouseDevice(
                  FlutterBluePlusBluetoothDevice(scanResult.device));
              try {
                await _devicesMutex.acquire();
                if (lighthouseDevice == null) {
                  lighthouseLogger.warning(
                      "${scanResult.device.platformName} ($deviceIdentifier): "
                      "Found a non valid device!",
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
          }
        });
    // Clean-up for when the stream is canceled.
    scanResultSubscription.onDone(() {
      _scanResultSubscription = null;
    });
    _scanResultSubscription = scanResultSubscription;
  }

  @override
  Stream<bool> get isScanning => blue_plus.FlutterBluePlus.isScanning;

  @override
  Stream<BluetoothAdapterState> get state =>
      blue_plus.FlutterBluePlus.adapterState.map((final event) {
        switch (event) {
          case blue_plus.BluetoothAdapterState.unknown:
            return BluetoothAdapterState.unknown;
          case blue_plus.BluetoothAdapterState.unavailable:
            return BluetoothAdapterState.unavailable;
          case blue_plus.BluetoothAdapterState.unauthorized:
            return BluetoothAdapterState.unauthorized;
          case blue_plus.BluetoothAdapterState.turningOn:
            return BluetoothAdapterState.turningOn;
          case blue_plus.BluetoothAdapterState.on:
            return BluetoothAdapterState.on;
          case blue_plus.BluetoothAdapterState.turningOff:
            return BluetoothAdapterState.turningOff;
          case blue_plus.BluetoothAdapterState.off:
            return BluetoothAdapterState.off;
        }
      });

  @override
  String get backendName => "FlutterBluePlusBackEnd";
}
