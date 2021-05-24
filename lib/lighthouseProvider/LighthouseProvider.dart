import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import 'adapterState/AdapterState.dart';
import 'DeviceProvider.dart';
import 'LighthouseDevice.dart';
import 'backEnd/LighthouseBackEnd.dart';
import 'backEnd/PairBackEnd.dart';
import 'ble/DeviceIdentifier.dart';
import 'timeout/TimeoutContainer.dart';

///A provider for getting all [LighthouseDevice]s in the area.
///
/// Before the provider actually becomes useful you will need to add at least
/// on [LighthouseBackEnd] to provide the provider with a back end to use. These
/// back ends must be provided with at least 1 [LighthouseProvider] or else the
/// back end won't know what devices are valid.
///
/// For basic usage:
/// Get an instance using [LighthouseProvider.instance].
/// Get a stream of valid [LighthouseDevice]s using [lighthouseDevices].\
/// Start scanning using [startScan]. (not the startScan form the [LighthouseBackEnd].
/// Stop scanning using [StopScan]. (not The stopScan from the [LighthouseBackEnd].
///
class LighthouseProvider {
  LighthouseProvider._() {
    WidgetsFlutterBinding.ensureInitialized();
  }

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
  final Mutex _lighthouseDeviceMutex = Mutex();
  BehaviorSubject<List<TimeoutContainer<LighthouseDevice>>> _lightHouseDevices =
      BehaviorSubject.seeded([]);
  StreamSubscription? _backEndResultSubscription;
  Set<LighthouseBackEnd> _backEndSet = Set();

  BehaviorSubject<bool> _isScanningBehavior = BehaviorSubject.seeded(false);
  StreamSubscription? _isScanningSubscription;

  Stream<bool> get isScanning => _isScanningBehavior.stream;

  Map<LighthouseBackEnd, StreamSubscription?> _stateSubscriptions = {};
  Map<LighthouseBackEnd, BluetoothAdapterState> _savedStates = {};
  BehaviorSubject<Map<LighthouseBackEnd, BluetoothAdapterState>> _state =
      BehaviorSubject.seeded({});

  Stream<BluetoothAdapterState> get state => _state.stream.map((map) {
        if (map.isEmpty) {
          return BluetoothAdapterState.unknown;
        }
        return map.values.reduce((value, element) {
          if (value == BluetoothAdapterState.on ||
              element == BluetoothAdapterState.on) {
            return BluetoothAdapterState.on;
          }
          return element;
        });
      });

  /// Add a back end for providing data.
  void addBackEnd(LighthouseBackEnd backEnd) {
    backEnd.updateLastSeen = _updateLastSeen;
    _backEndSet.add(backEnd);
    _addStateSubscription(backEnd);
  }

  /// Remove a back end for providing data.
  void removeBackEnd(LighthouseBackEnd backEnd) {
    if (_backEndSet.remove(backEnd)) {
      backEnd.updateLastSeen = null;
    }
    _removeStateSubscription(backEnd);
  }

  ///
  /// Get all the back ends that have to pair first before they can communicate
  /// with a device.
  ///
  List<PairBackEnd> getPairBackEnds() {
    final List<PairBackEnd> backEnds = [];
    for (final backEnd in _backEndSet) {
      if (backEnd is PairBackEnd) {
        backEnds.add(backEnd as PairBackEnd);
      }
    }
    return backEnds;
  }

  ///
  /// Check if all the back ends installed all require to be paired first.
  /// If one of the back ends doesn't require it then this will return `false`
  /// else this will return `true`.
  ///
  bool hasOnlyPairBackends() {
    for (final backEnd in _backEndSet) {
      if (!backEnd.isPairBackEnd) {
        return false;
      }
    }
    return true;
  }

  void _addStateSubscription(LighthouseBackEnd backEnd) {
    if (_stateSubscriptions.containsKey(backEnd)) {
      return;
    }
    _stateSubscriptions[backEnd] = backEnd.state.listen((newState) {
      _savedStates[backEnd] = newState;
      _state.add(_savedStates);
    });
  }

  void _removeStateSubscription(LighthouseBackEnd backEnd) {
    _stateSubscriptions[backEnd]?.cancel();
    _savedStates.remove(backEnd);
    _state.add(_savedStates);
  }

  /// Get a list of all the back ends that this [DeviceProvider] can be used with.
  List<LighthouseBackEnd> _getBackEndForDeviceProvider(
      DeviceProvider provider) {
    final List<LighthouseBackEnd> backEndList = <LighthouseBackEnd>[];
    for (final backEnd in _backEndSet) {
      if (backEnd.isMyProviderType(provider)) {
        backEndList.add(backEnd);
      }
    }
    return backEndList;
  }

  /// Add a [DeviceProvider] to every [LighthouseBackEnd] that supports it.
  ///
  /// Will throw a [UnsupportedError] if no valid back end could be found for the
  /// [DeviceProvider].
  void addProvider(DeviceProvider provider) {
    final backEndList = _getBackEndForDeviceProvider(provider);
    if (backEndList.isEmpty) {
      throw UnsupportedError(
          'No back end found for device provider: "${provider.runtimeType}". Did you forget to add the back end first?');
    }
    for (final backEnd in backEndList) {
      backEnd.addProvider(provider);
    }
  }

  /// Remove a [DeviceProvider] from every [LighthouseBackEnd] that supports it.
  ///
  /// Will throw a [UnsupportedError] if no valid back end could be found for the
  /// [DeviceProvider].
  void removeProvider(DeviceProvider provider) {
    final backEndList = _getBackEndForDeviceProvider(provider);
    if (backEndList.isEmpty) {
      throw UnsupportedError(
          'No back end found for device provider: "${provider.runtimeType}". Did you forget to add the back end first?');
    }
    for (final backEnd in backEndList) {
      backEnd.removeProvider(provider);
    }
  }

  /// Start scanning for [LighthouseDevice]s.
  ///
  /// This will clear the old "known" [LighthouseDevice]s and start searching
  /// for new ones.
  ///
  /// Will call the [cleanUp] function before starting the scan.
  Future startScan(
      {required Duration timeout, Duration? updateInterval}) async {
    await _startIsScanningSubscription();
    await cleanUp();
    await _startListeningScanResults();
    for (final backEnd in _backEndSet) {
      /// Only start the scan if the back-end acknowledges that it's bluetooth
      /// adapter state is on.
      if (_savedStates[backEnd] == BluetoothAdapterState.on) {
        // may need to add await back again depending on how the providers react to being multi-threaded.
        backEnd.startScan(timeout: timeout, updateInterval: updateInterval);
      }
    }
  }

  ///
  /// Clean up any open connections that may still be left.
  /// Will also clear out the current devices list.
  ///
  Future cleanUp() async {
    await stopScan();
    await _disconnectOpenDevices();
    for (final backEnd in _backEndSet) {
      await backEnd.cleanUp();
    }
    _lightHouseDevices.add([]);
    if (_lighthouseDeviceMutex.isLocked) {
      _lighthouseDeviceMutex.release();
    }
  }

  /// Stop scanning for [LighthouseDevice]s.
  ///
  /// This wil **NOT** clear the "known" [LighthouseDevice]s so the
  /// [lighthouseDevices] will still contain the (at the time of stopping)
  /// valid [LighthouseDevice]s.
  Future stopScan() async {
    this._backEndResultSubscription?.pause();
    for (final backEnd in _backEndSet) {
      await backEnd.stopScan();
    }
  }

  /// Start combining all [isScanning] from the back end providers.
  Future<void> _startIsScanningSubscription() async {
    var isScanningSubscription = _isScanningSubscription;
    if (isScanningSubscription != null) {
      await isScanningSubscription.cancel();
      _isScanningSubscription = null;
    }

    final List<Stream<Tuple2<int, bool>>> streams = _backEndSet
        .map((element) => element.isScanning)
        .where((stream) => stream != null)
        .toList(growable: false)
        .asMap()
        .entries
        .map((entry) =>
            entry.value!.map((event) => Tuple2<int, bool>(entry.key, event)))
        .toList(growable: false);

    final List<bool> scanResults = List<bool>.filled(streams.length, false);
    for (var i = 0; i < scanResults.length; i++) {
      scanResults[i] = false;
    }

    isScanningSubscription =
        MergeStream<Tuple2<int, bool>>(streams).map<bool>((scanning) {
      if (scanning.item1 >= 0 && scanning.item1 < scanResults.length) {
        scanResults[scanning.item1] = scanning.item2;
      }
      return scanResults.reduce((value, element) => value || element);
    }).listen((isScanning) {
      this._isScanningBehavior.add(isScanning);
    });

    this._isScanningSubscription = isScanningSubscription;
  }

  /// Update the last time a device has been seen.
  ///
  /// This will update the last time a device with teh [deviceIdentifier] has
  /// been seen and return a bool if this was successful.
  bool _updateLastSeen(LHDeviceIdentifier deviceIdentifier) {
    final list = _lightHouseDevices.value;
    if (list == null) {
      return false;
    }
    final device = list.cast<TimeoutContainer<LighthouseDevice>?>().firstWhere(
        (element) => element?.data.deviceIdentifier == deviceIdentifier,
        orElse: () => null);
    if (device == null) {
      return false;
    }
    device.lastSeen = DateTime.now();
    return true;
  }

  /// Disconnect from all known and open devices.
  Future _disconnectOpenDevices() async {
    for (final backEnd in _backEndSet) {
      await backEnd.disconnectOpenDevices();
    }
    final list = this._lightHouseDevices.value;
    for (final device in list ?? []) {
      await device.data.disconnect();
    }
  }

  /// Combine the output streams from all the back-ends and add combine all their
  /// returned [LighthouseDevice]s.
  Future _startListeningScanResults() async {
    var backEndResultSubscription = this._backEndResultSubscription;
    if (backEndResultSubscription != null) {
      if (!backEndResultSubscription.isPaused) {
        backEndResultSubscription.pause();
      }
      await backEndResultSubscription.cancel();
      this._backEndResultSubscription = null;
    }

    final streams = <Stream<LighthouseDevice?>>[];
    for (final backEnd in _backEndSet) {
      streams.add(backEnd.lighthouseStream);
    }

    backEndResultSubscription = MergeStream(streams).listen((newDevice) async {
      if (newDevice == null) {
        return;
      }
      if (_updateLastSeen(newDevice.deviceIdentifier)) {
        return;
      }
      try {
        await _lighthouseDeviceMutex.acquire();
        final List<TimeoutContainer<LighthouseDevice>> list =
            this._lightHouseDevices.value ?? [];
        // Check if this device is already in the list, which should never happen.
        if (list.cast<TimeoutContainer<LighthouseDevice>?>().firstWhere(
                (element) {
              if (element != null) {
                return element.data == newDevice;
              }
              return false;
            }, orElse: () => null) !=
            null) {
          debugPrint(
              'Found a device that has already been found! Device id: ${newDevice.deviceIdentifier}, name: ${newDevice.name}');
          return;
        }

        list.add(TimeoutContainer<LighthouseDevice>(newDevice));
        this._lightHouseDevices.add(list);
      } finally {
        if (_lighthouseDeviceMutex.isLocked) {
          _lighthouseDeviceMutex.release();
        }
      }
    });
    // Clean-up for when the stream is canceled.
    backEndResultSubscription.onDone(() {
      this._backEndResultSubscription = null;
    });
    this._backEndResultSubscription = backEndResultSubscription;
  }
}
