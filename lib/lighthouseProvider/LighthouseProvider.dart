import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:rxdart/transformers.dart';

import 'timeout/TimeoutContainer.dart';

///A provider for getting all [LighthouseDevice]s in the region.
///
/// The provider uses [FlutterBlue] and "overrides" the [startScan] and
/// [stopScan] methods.
///
/// For basic usage:
/// Get an instance using [LighthouseProvider.instance].
/// Get a stream of valid [LighthouseDevice]s using [lighthouseDevices].\
/// Start scanning using [startScan]. (not the startScan form [FlutterBlue].
/// Stop scanning using [StopScan]. (not The stopScan from [FlutterBlue].
///
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
      _lightHouseDevices.stream
          .map((devices) => devices.map((device) => device.data).toList());

  /// Get an instance of [LighthouseProvider].
  static get instance {
    return LighthouseProvider._instance;
//    return LighthouseProviderFake.instance;
  }

  static final _instance = LighthouseProvider._();
  Set<DeviceIdentifier> _connectingDevices = Set();
  BehaviorSubject<List<TimeoutContainer<LighthouseDevice>>> _lightHouseDevices =
      BehaviorSubject.seeded([]);

  /// Start scanning for [LighthouseDevice]s.
  ///
  /// This will clear the old "known" [LighthouseDevice]s and start searching
  /// for new ones.
  ///
  /// Will call the [FlutterBlue.startScan] function in the background.
  Future startScan({
    ScanMode scanMode = ScanMode.lowLatency,
    Duration timeout,
  }) async {
    this._disconnectOpenDevices();
    this._lightHouseDevices.add(List());
    this._connectingDevices.clear();
    this._startListeningScanResults();
    await FlutterBlue.instance
        .startScan(scanMode: scanMode, timeout: timeout, allowDuplicates: true);
  }

  /// Stop scanning for [LighthouseDevice]s.
  ///
  /// This wil **NOT** clear the "known" [LighthouseDevice]s so the
  /// [lighthouseDevices] will still contain the (at the time of stopping)
  /// valid [LighthouseDevice]s.
  Future stopScan() async {
    this._scanResultSubscription.pause();
    await FlutterBlue.instance.stopScan();
  }

  /// Get the index of a found device based on the scan result.
  ///
  /// Wil return the index of the device in the [_lightHouseDevices.value]
  /// [List] or `-1` if not found.
  int _foundDeviceIndex(ScanResult device) {
    int index = 0;
    for (final activeDevice in this._lightHouseDevices.value) {
      if (device.device.id == activeDevice.data.id) {
        return index;
      }
      index++;
    }
    return -1;
  }

  /// Disconnect from all known and open devices.
  Future _disconnectOpenDevices() async {
    final list = this._lightHouseDevices.value;
    for (final device in list) {
      await device.data.disconnect();
    }
  }

  StreamSubscription _scanResultSubscription;

  /// Start the stream for listening to the [LighthouseDevice]s.
  ///
  /// This will try and re-use a previous active stream if one already exists.
  void _startListeningScanResults() {
    if (_scanResultSubscription != null) {
      if (_scanResultSubscription.isPaused) {
        _scanResultSubscription.resume();
        return;
      }
      _scanResultSubscription.cancel();
    }

    _scanResultSubscription = FlutterBlue.instance.scanResults
        .map((devices) {
          // Filter out all devices who's name doesn't start with `LHB-`.
          final List<ScanResult> output = List();
          for (final device in devices) {
            if (device.device.name.startsWith('LHB-')) {
              output.add(device);
            } else {
              //debugPrint(
              //    'Filtered out device that didn\'t have the correct name. Mac: ${device.device.id.toString()}');
            }
          }
          return output;
        })
        // Give the listener at least 2ms to process the data before firing again.
        .debounce((_) => TimerStream(true, Duration(milliseconds: 2)))
        .listen((devices) {
          for (final device in devices) {
            if (this._connectingDevices.contains(device.device.id)) {
              debugPrint(
                  'Found a device that is already being scanned. Mac: ${device.device.id.toString()}');
              continue;
            }
            final index = this._foundDeviceIndex(device);
            if (index >= 0) {
              debugPrint(
                  'Found a device that was already known. Mac: ${device.device.id.toString()}');
              this._lightHouseDevices.value[index].lastSeen = DateTime.now();
              continue;
            }

            // A new [LighthouseDevice], let's make sure it's valid.
            final lighthouseDevice = LighthouseDevice(device.device);
            this._connectingDevices.add(device.device.id);
            lighthouseDevice.isValid().then((valid) {
              if (valid) {
                debugPrint(
                    'Found a new lighthouse! Mac: ${device.device.id.toString()}');
                // Add the new device to the list and publish it to the stream.
                final list = this._lightHouseDevices.value;
                list.add(TimeoutContainer<LighthouseDevice>(lighthouseDevice));
                this._lightHouseDevices.add(list);
              } else {
                debugPrint(
                    'Found a non valid device! Mac: ${device.device.id.toString()}');
              }
              this._connectingDevices.remove(device.device.id);
            });
          }
        });
    // Clean-up for when the stream is canceled.
    _scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
  }
}

/// A [LighthouseProvider] that always returns fake data and doesn't actually
/// communicate with any bluetooth service.
///
/// This is only used for testing and creating screenshots.
class LighthouseProviderFake extends LighthouseProvider {
  LighthouseProviderFake._() : super._();

  @override
  Future stopScan() async {
    return;
  }

  @override
  Future startScan(
      {ScanMode scanMode = ScanMode.lowLatency, Duration timeout}) async {
    this._lighthouseDevicesFake.add(List());
    final list = this._lighthouseDevicesFake.value;
    await Future.delayed(new Duration(milliseconds: 300));
    list.add(new LighthouseDeviceFake());
    this._lighthouseDevicesFake.add(list);
    await Future.delayed(new Duration(milliseconds: 400));
    list.add(new LighthouseDeviceFake());
    this._lighthouseDevicesFake.add(list);
  }

  BehaviorSubject<List<LighthouseDevice>> _lighthouseDevicesFake =
      BehaviorSubject.seeded([]);

  @override
  Stream<List<LighthouseDevice>> get lighthouseDevices =>
      _lighthouseDevicesFake.stream;

  static LighthouseProviderFake _instance;

  static LighthouseProviderFake get instance {
    if (LighthouseProviderFake._instance == null) {
      LighthouseProviderFake._instance = LighthouseProviderFake._();
    }
    return LighthouseProviderFake._instance;
  }
}
