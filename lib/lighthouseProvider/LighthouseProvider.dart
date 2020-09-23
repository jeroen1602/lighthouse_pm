import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'DeviceProvider.dart';
import 'LighthouseDevice.dart';
import 'backend/LighthouseBackend.dart';
import 'ble/DeviceIdentifier.dart';
import 'timeout/TimeoutContainer.dart';

///A provider for getting all [LighthouseDevice]s in the region.
///
/// The provider uses [LighthouseBackend] and "overrides" the [startScan] and
/// [stopScan] methods.
///
/// For basic usage:
/// Get an instance using [LighthouseProvider.instance].
/// Get a stream of valid [LighthouseDevice]s using [lighthouseDevices].\
/// Start scanning using [startScan]. (not the startScan form the [LighthouseBackend].
/// Stop scanning using [StopScan]. (not The stopScan from the [LighthouseBackend].
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
      _lightHouseDevices.stream.map((containers) =>
          containers.map((container) => container.data).toList());

  /// Get an instance of [LighthouseProvider].
  static LighthouseProvider get instance {
    return LighthouseProvider._instance;
  }

  static final LighthouseProvider _instance = LighthouseProvider._();
  BehaviorSubject<List<TimeoutContainer<LighthouseDevice>>> _lightHouseDevices =
      BehaviorSubject.seeded([]);
  StreamSubscription /* ? */ _backendResultSubscription;
  Set<LighthouseBackend> _backendSet = Set();

  /// Add a backend for providing data.
  void addBackend(LighthouseBackend backend) {
    backend.updateLastSeen = _updateLastSeen;
    _backendSet.add(backend);
  }

  /// Remove a backend for providing data.
  void removeBackend(LighthouseBackend backend) {
    if (_backendSet.remove(backend)) {
      backend.updateLastSeen = null;
    }
  }

  LighthouseBackend /* ? */ getBackendForDeviceProvider(
      DeviceProvider provider) {
    for (final backend in _backendSet) {
      if (backend.isMyProviderType(provider)) {
        return backend;
      }
    }
    return null;
  }

  /// Add a [DeviceProvider] to the first [LighthouseBackend] that supports it.
  ///
  /// Will throw a [UnsupportedError] if no valid backend could be found for the
  /// [DeviceProvider].
  void addProvider(DeviceProvider provider) {
    final backend = getBackendForDeviceProvider(provider);
    if (backend == null) {
      throw UnsupportedError(
          'No backend found for device provider: "${provider.runtimeType}". Did you forget to add the backend first?');
    }
    backend.addProvider(provider);
  }

  /// Remove a [DeviceProvider] to the first [LighthouseBackend] that supports it.
  ///
  /// Will throw a [UnsupportedError] if no valid backend could be found for the
  /// [DeviceProvider].
  void removeProvider(DeviceProvider provider) {
    final backend = getBackendForDeviceProvider(provider);
    if (backend == null) {
      throw UnsupportedError(
          'No backend found for device provider: "${provider.runtimeType}". Did you forget to add the backend first?');
    }
    backend.removeProvider(provider);
  }

  /// Start scanning for [LighthouseDevice]s.
  ///
  /// This will clear the old "known" [LighthouseDevice]s and start searching
  /// for new ones.
  ///
  /// Will call the [cleanUp] function before starting the scan.
  Future startScan({
    @required Duration timeout,
  }) async {
    await cleanUp();
    await _startListeningScanResults();
    for (final backend in _backendSet) {
      await backend.startScan(timeout: timeout);
    }
  }

  ///
  /// Clean up any open connections that may still be left.
  /// Will also clear out the current devices list.
  ///
  Future cleanUp() async {
    await stopScan();
    await _disconnectOpenDevices();
    for (final backend in _backendSet) {
      await backend.cleanUp();
    }
    _lightHouseDevices.add(List());
  }

  /// Stop scanning for [LighthouseDevice]s.
  ///
  /// This wil **NOT** clear the "known" [LighthouseDevice]s so the
  /// [lighthouseDevices] will still contain the (at the time of stopping)
  /// valid [LighthouseDevice]s.
  Future stopScan() async {
    if (this._backendResultSubscription != null) {
      this._backendResultSubscription.pause();
    }
    for (final backend in _backendSet) {
      await backend.stopScan();
    }
  }

  /// Update the last time a device has been seen.
  ///
  /// This will update the last time a device with teh [deviceIdentifier] has
  /// been seen and return a bool if this was successful.
  bool _updateLastSeen(LHDeviceIdentifier deviceIdentifier) {
    final device = _lightHouseDevices.value.firstWhere(
        (element) => element.data.deviceIdentifier == deviceIdentifier,
        orElse: () => null);
    if (device == null) {
      return false;
    }
    device.lastSeen = DateTime.now();
    return true;
  }

  /// Disconnect from all known and open devices.
  Future _disconnectOpenDevices() async {
    for (final backend in _backendSet) {
      await backend.disconnectOpenDevices();
    }
    final list = this._lightHouseDevices.value;
    for (final device in list) {
      await device.data.disconnect();
    }
  }

  /// Combine the output streams from all the back-ends and add combine all their
  /// returned [LighthouseDevice]s.
  Future _startListeningScanResults() async {
    if (_backendResultSubscription != null) {
      if (!_backendResultSubscription.isPaused) {
        _backendResultSubscription.pause();
      }
      await _backendResultSubscription.cancel();
      _backendResultSubscription = null;
    }

    final streams = <Stream<LighthouseDevice /* ? */ >>[];
    for (final backend in _backendSet) {
      streams.add(backend.lighthouseStream);
    }

    _backendResultSubscription = MergeStream(streams).listen((newDevice) {
      if (newDevice == null) {
        return;
      }
      final list = this._lightHouseDevices.value;
      // Check if this device is already in the list, which should never happen.
      if (list.firstWhere((element) => element.data == newDevice,
              orElse: () => null) !=
          null) {
        debugPrint(
            'Found a device that has already been found! mac: ${newDevice.deviceIdentifier}, name: ${newDevice.name}');
        return;
      }
      list.add(TimeoutContainer<LighthouseDevice>(newDevice));
      this._lightHouseDevices.add(list);
      this._lightHouseDevices.add(list);
    });
    // Clean-up for when the stream is canceled.
    _backendResultSubscription.onDone(() {
      this._backendResultSubscription = null;
    });
  }
}
