import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:lighthouse_pm/lighthouseProvider/backEnd/BlueZ/BlueZBluetoothDevice.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import 'BLELighthouseBackEnd.dart';

/// A back end that provides devices using [BlueZClient].
class BlueZBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance;
  static BlueZBackEnd? _instance;

  BlueZBackEnd._();

  static BlueZBackEnd get instance => _instance ??= BlueZBackEnd._();

  // Some state variables.
  final Mutex _devicesMutex = Mutex();

  BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;
  final BlueZClient blueZClient = BlueZClient();

  StreamSubscription<void>? _stopScan;

  BehaviorSubject<bool> _scanningSubject = BehaviorSubject.seeded(false);

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state async* {
    await _ensureConnected();
    yield* MergeStream<dynamic>([
      Stream.value(blueZClient.devices), // Always fires at least once
      blueZClient.adapterAdded,
      blueZClient.adapterRemoved
    ]).map((event) {
      return blueZClient.adapters;
    }).map((adapters) {
      if (adapters.isEmpty) {
        return BluetoothAdapterState.unavailable;
      }
      for (final adapter in adapters) {
        if (adapter.powered) {
          return BluetoothAdapterState.on;
        }
      }
      return BluetoothAdapterState.off;
    });
  }

  Stream<bool>? get isScanning => _scanningSubject.stream;

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _ensureConnected();
    await _startListeningScanResults();
    try {
      final adapters =
          blueZClient.adapters.where((adapter) => adapter.powered).toList();
      if (adapters.isNotEmpty) {
        _scanningSubject.add(true);
      }
      await Future.wait(adapters.map((adapter) {
        // TODO: we may need this, but probably not.
        //adapter.setDiscoveryFilter(filter);
        return adapter.startDiscovery();
      }));
      _stopScan = Future.delayed(timeout).asStream().listen((event) {
        _stopScan = null;
        _scanningSubject.add(false);
        stopScan();
      });
    } catch (e, s) {
      print("Error with BlueZ scanning $e\n$s");
    }
  }

  @override
  Future<void> cleanUp() async {
    _foundDeviceSubject.add(null);
    if (_devicesMutex.isLocked) {
      _devicesMutex.release();
    }
  }

  @override
  Future<void> stopScan() async {
    await _ensureConnected();
    _scanResultSubscription?.pause();
    _stopScan?.cancel();
    _stopScan = null;
    await Future.wait(blueZClient.adapters
        .where((adapter) => adapter.powered && adapter.discovering)
        .map((adapter) async {
      try {
        await adapter.stopDiscovery();
      } catch (e, s) {
        print(
            "Cannot stop discovery because: ${e.toString()}\n${s.toString()}");
      }
    }));
    _scanningSubject.add(false);
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

    scanResultSubscription = MergeStream(
            [Stream.fromIterable(blueZClient.devices), blueZClient.deviceAdded])
        .where((device) {
          //TODO: Maybe move this to be a bit more generic.
          // Filter out all devices that don't have a correct name.
          for (final deviceProvider in providers) {
            if (deviceProvider.nameCheck(device.name)) {
              return true;
            }
          }
          return false;
        })
        // Give the listener at least 2ms to process the data before firing again.
        .debounce((_) => TimerStream(true, Duration(milliseconds: 2)))
        .listen((device) async {
          await device.setTrusted(true);
          final lighthouseDevice =
              await getLighthouseDevice(BlueZBluetoothDevice(device));
          try {
            await _devicesMutex.acquire();
            if (lighthouseDevice == null) {
              print('Found a non valid device! Device id: ${device.address}');
            } else {
              this._foundDeviceSubject.add(lighthouseDevice);
            }
          } finally {
            if (_devicesMutex.isLocked) {
              _devicesMutex.release();
            }
          }
        });
    // Clean-up for when the stream is canceled.
    scanResultSubscription.onDone(() {
      this._scanResultSubscription = null;
    });
    this._scanResultSubscription = scanResultSubscription;
  }

  Future<void> _ensureConnected() async {
    await blueZClient.connect();
  }
}
