library flutter_blue_back_end;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_platform/shared_platform.dart';

part 'ble/flutter_blue_bluetooth_characteristic.dart';

part 'ble/flutter_blue_bluetooth_device.dart';

part 'ble/flutter_blue_bluetooth_service.dart';

part 'helpers/flutter_blue_extensions.dart';

/// A back end that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackEnd? _instance;

  FlutterBlueLighthouseBackEnd._();

  static FlutterBlueLighthouseBackEnd get instance {
    return _instance ??= FlutterBlueLighthouseBackEnd._();
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
  /// Will call the [FlutterBlue.startScan] function in the background.
  @override
  Future<void> startScan(
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _startListeningScanResults();
    try {
      await FlutterBlue.instance.startScan(
          scanMode: ScanMode.lowLatency,
          timeout: timeout,
          allowDuplicates: true);
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
      await FlutterBlue.instance.stopScan();
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
        .map((final scanResults) {
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
        .debounce(
            (final _) => TimerStream(true, const Duration(milliseconds: 2)))
        .listen((final scanResults) {
          if (scanResults.isEmpty) {
            return;
          }
          for (final scanResult in scanResults) {
            final deviceIdentifier =
                scanResult.device.id.toLHDeviceIdentifier();

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
                  FlutterBlueBluetoothDevice(scanResult.device));
              try {
                await _devicesMutex.acquire();
                if (lighthouseDevice == null) {
                  lighthouseLogger.warning(
                      "Found a non valid device! Device id: "
                      "${scanResult.device.id.toString()}",
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
  Stream<bool> get isScanning => FlutterBlue.instance.isScanning;

  @override
  Stream<BluetoothAdapterState> get state =>
      FlutterBlue.instance.state.map((final event) {
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