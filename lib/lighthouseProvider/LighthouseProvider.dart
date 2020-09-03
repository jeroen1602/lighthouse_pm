import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/BLEDeviceProvider.dart';
import 'package:rxdart/rxdart.dart';

import 'LighthouseDevice.dart';
import 'timeout/TimeoutContainer.dart';

class LighthouseProvider {
  LighthouseProvider._();

  /// Get a stream with a [List] of valid [LighthouseDevice]s.
  ///
  /// The [LighthouseDevice]s returned by this stream are all valid, by calling
  /// the [LighthouseDevice.isValid] method. If a [LighthouseDevice] happens to
  /// not be valid then it won't be in this list.
  ///
  /// This list (should) only contain [LighthouseDevice]s devices that are
  /// currently in range without any duplicates.
  ///
  /// Make sure to call [startScan] in order to start getting a [List] of
  /// [LighthouseDevice]s.
  ///
  Stream<List<LighthouseDevice>> get lighthouseDevices =>
      _lightHouseDevices.stream.map((containers) =>
          containers.map((container) => container.data).toList());

  /// Get an instance of [LighthouseProvider].
  static LighthouseProvider get instance {
    return LighthouseProvider._instance;
  }

  static final LighthouseProvider _instance = LighthouseProvider._();
  Set<LHDeviceIdentifier> _connectingDevices = Set();
  Set<LHDeviceIdentifier> _rejectedDevices = Set();
  BehaviorSubject<List<TimeoutContainer<LighthouseDevice>>> _lightHouseDevices =
      BehaviorSubject.seeded([]);
  StreamSubscription _scanResultSubscription;
  Set<BLEDeviceProvider> _bleDeviceProviders = Set();

  void addBLEDeviceProvider(BLEDeviceProvider bleDeviceProvider) {
    _bleDeviceProviders.add(bleDeviceProvider);
  }

  void removeBLEDeviceProvider(BLEDeviceProvider bleDeviceProvider) {
    _bleDeviceProviders.remove(bleDeviceProvider);
  }

  /// Start scanning for [LighthouseDevice]s.
  ///
  /// This will clear the old "known" [LighthouseDevice]s and start searching
  /// for new ones.
  ///
  /// Will call the [cleanUp] function before starting the scan.
  /// Will call the [FlutterBlue.startScan] function in the background.
  Future startScan({
    ScanMode scanMode = ScanMode.lowLatency,
    Duration timeout,
  }) async {
    await cleanUp();
    await _startListeningScanResults();
    await FlutterBlue.instance
        .startScan(scanMode: scanMode, timeout: timeout, allowDuplicates: true);
  }

  ///
  /// Clean up any open connections that may still be left.
  /// Will also clear out the current devices list.
  ///
  Future cleanUp() async {
    await stopScan();
    await _disconnectOpenDevices();
    _lightHouseDevices.add(List());
    _connectingDevices.clear();
    _rejectedDevices.clear();
  }

  /// Stop scanning for [LighthouseDevice]s.
  ///
  /// This wil **NOT** clear the "known" [LighthouseDevice]s so the
  /// [lighthouseDevices] will still contain the (at the time of stopping)
  /// valid [LighthouseDevice]s.
  Future stopScan() async {
    if (this._scanResultSubscription != null) {
      this._scanResultSubscription.pause();
    }
    await FlutterBlue.instance.stopScan();
  }

  /// Get the index of a found device based on the scan result.
  ///
  /// Wil return the index of the device in the [_lightHouseDevices.value]
  /// [List] or `-1` if not found.
  int _foundDeviceIndex(LHDeviceIdentifier deviceIdentifier) {
    int index = 0;
    for (final activeDevice in this._lightHouseDevices.value) {
      if (deviceIdentifier == activeDevice.data.deviceIdentifier) {
        return index;
      }
      index++;
    }
    return -1;
  }

  /// Disconnect from all known and open devices.
  Future _disconnectOpenDevices() async {
    for (final bleDeviceProvider in _bleDeviceProviders) {
      await bleDeviceProvider.disconnectRunningDiscoveries();
    }
    final list = this._lightHouseDevices.value;
    for (final device in list) {
      await device.data.disconnect();
    }
  }

  /// Start the stream for listening to the [LighthouseDevice]s.
  Future _startListeningScanResults() async {
    if (_scanResultSubscription != null) {
      if (!_scanResultSubscription.isPaused) {
        _scanResultSubscription.pause();
      }
      await _scanResultSubscription.cancel();
      _scanResultSubscription = null;
    }

    _scanResultSubscription = FlutterBlue.instance.scanResults
        .map((scanResults) {
          // Filter out all devices that don't have a correct name.
          final List<ScanResult> output = List();
          for (final scanResult in scanResults) {
            for (final bleDeviceProviders in _bleDeviceProviders) {
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
            if (this._connectingDevices.contains(
                LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id))) {
              continue;
            }
            if (this._rejectedDevices.contains(
                LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id))) {
              continue;
            }
            // Update the last seen item.
            final index = this._foundDeviceIndex(
                LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id));
            if (index >= 0) {
              this._lightHouseDevices.value[index].lastSeen = DateTime.now();
              continue;
            }
            // Possibly a new lighthouse, let's make sure it's valid.
            this
                ._connectingDevices
                .add(LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id));
            _getLighthouseDevice(scanResult.device).then((lighthouseDevice) {
              if (lighthouseDevice == null) {
                debugPrint(
                    'Found a non valid device! Mac: ${scanResult.device.id.toString()}');
                this._rejectedDevices.add(
                    LHDeviceIdentifier.fromFlutterBlue(scanResult.device.id));
              } else {
                final list = this._lightHouseDevices.value;
                list.add(TimeoutContainer<LighthouseDevice>(lighthouseDevice));
                this._lightHouseDevices.add(list);
              }
              this._connectingDevices.remove(scanResult.device.id);
            });
          }
        });
    // Clean-up for when the stream is canceled.
    _scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
  }

  ///
  /// Will return `null` if no device provider could validate the device.
  Future<LighthouseDevice> _getLighthouseDevice(BluetoothDevice device) async {
    debugPrint('Trying to connect to device with name: ${device.name}');
    for (final bLEDeviceProvider in _bleDeviceProviders) {
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
