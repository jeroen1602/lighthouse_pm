import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import '../ble/DeviceIdentifier.dart';
import 'BLELighthouseBackend.dart';

/// A backend that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackend extends BLELighthouseBackend {
  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackend /* ? */ _instance;

  FlutterBlueLighthouseBackend._();

  static FlutterBlueLighthouseBackend get instance {
    if (_instance == null) {
      _instance = FlutterBlueLighthouseBackend._();
    }
    return _instance;
  }

  // Some state variables.
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
            for (final bleDeviceProviders in providers) {
              if (bleDeviceProviders.nameCheck(scanResult.device.name)) {
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
                LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id);

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
            this._connectingDevices.add(deviceIdentifier);
            _getLighthouseDevice(scanResult.device).then((lighthouseDevice) {
              if (lighthouseDevice == null) {
                debugPrint(
                    'Found a non valid device! Mac: ${scanResult.device.id.toString()}');
                this._rejectedDevices.add(deviceIdentifier);
              } else {
                this._foundDeviceSubject.add(lighthouseDevice);
              }
              this._connectingDevices.remove(deviceIdentifier);
            });
          }
        });
    // Clean-up for when the stream is canceled.
    _scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
  }

  /// Will return `null` if no device provider could validate the device.
  Future<LighthouseDevice /* ? */ > _getLighthouseDevice(
      BluetoothDevice device) async {
    debugPrint('Trying to connect to device with name: ${device.name}');
    for (final bLEDeviceProvider in providers) {
      if (!bLEDeviceProvider.nameCheck(device.name)) {
        continue;
      }
      final LighthouseDevice lighthouseDevice =
          await bLEDeviceProvider.getDevice(device);
      if (lighthouseDevice != null) {
        return lighthouseDevice;
      }
    }
    return null;
  }
}
