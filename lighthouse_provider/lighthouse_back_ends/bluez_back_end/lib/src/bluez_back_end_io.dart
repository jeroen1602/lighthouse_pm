library bluez_back_end;

import 'dart:async';
import 'dart:typed_data';

import 'package:bluez/bluez.dart';
import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:lighthouse_logger/lighthouse_logger.dart';

part 'ble/bluez_bluetooth_characteristic.dart';

part 'ble/bluez_bluetooth_device.dart';

part 'ble/bluez_bluetooth_service.dart';

/// A back end that provides devices using [BlueZClient].
class BlueZBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance;
  static BlueZBackEnd? _instance;

  BlueZBackEnd._();

  static BlueZBackEnd get instance {
    return _instance ??= BlueZBackEnd._();
  }

  // Some state variables.
  final Mutex _devicesMutex = Mutex();

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);
  StreamSubscription? _scanResultSubscription;
  final BlueZClient blueZClient = BlueZClient();

  StreamSubscription<void>? _stopScan;

  final BehaviorSubject<bool> _scanningSubject = BehaviorSubject.seeded(false);

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state async* {
    await _ensureConnected();
    yield* MergeStream<dynamic>([
      Stream.value(blueZClient.devices), // Always fires at least once
      blueZClient.adapterAdded,
      blueZClient.adapterRemoved
    ]).map((final event) {
      return blueZClient.adapters;
    }).map((final adapters) {
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

  @override
  Stream<bool>? get isScanning => _scanningSubject.stream;

  @override
  Future<void> startScan(
      {required final Duration timeout,
      required final Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    await _ensureConnected();
    await _startListeningScanResults();
    try {
      final adapters = blueZClient.adapters
          .where((final adapter) => adapter.powered)
          .toList();
      if (adapters.isNotEmpty) {
        _scanningSubject.add(true);
      }
      await Future.wait(adapters.map((final adapter) {
        // TODO: we may need this, but probably not.
        //adapter.setDiscoveryFilter(filter);
        return adapter.startDiscovery();
      }));
      _stopScan = Future.delayed(timeout).asStream().listen((final event) {
        _stopScan = null;
        _scanningSubject.add(false);
        stopScan();
      });
    } catch (e, s) {
      lighthouseLogger.severe("Error with BlueZ scanning", e, s);
    }
  }

  @override
  Future<void> cleanUp({final bool onlyDisconnected = false}) async {
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
        .where((final adapter) => adapter.powered && adapter.discovering)
        .map((final adapter) async {
      try {
        await adapter.stopDiscovery();
      } catch (e, s) {
        lighthouseLogger.severe("Cannot stop discovery", e, s);
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
        .where((final device) {
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
        .debounce((final _) => TimerStream(true, Duration(milliseconds: 2)))
        .listen((final device) async {
          await device.setTrusted(true);
          final lighthouseDevice =
              await getLighthouseDevice(BlueZBluetoothDevice(device));
          try {
            await _devicesMutex.acquire();
            if (lighthouseDevice == null) {
              lighthouseLogger.warning(
                  "Found a not valid device! Device id: ${device.address}");
            } else {
              _foundDeviceSubject.add(lighthouseDevice);
            }
          } finally {
            if (_devicesMutex.isLocked) {
              _devicesMutex.release();
            }
          }
        });
    // Clean-up for when the stream is canceled.
    scanResultSubscription.onDone(() {
      _scanResultSubscription = null;
    });
    _scanResultSubscription = scanResultSubscription;
  }

  Future<void> _ensureConnected() async {
    await blueZClient.connect();
  }

  @override
  String get backendName => "BluezBackEnd";
}
