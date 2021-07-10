import 'package:bluez/bluez.dart';
import 'package:rxdart/rxdart.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import 'BLELighthouseBackEnd.dart';

/// A back end that provides devices using [BlueZClient].
class BlueZBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance;
  static BlueZBackEnd? _instance;

  BlueZBackEnd._();

  static BlueZBackEnd get instance {
    if (_instance == null) {
      _instance = BlueZBackEnd._();
    }
    return _instance!;
  }

  final BlueZClient blueZClient = BlueZClient();

  @override
  // TODO: implement lighthouseStream
  Stream<LighthouseDevice?> get lighthouseStream => throw UnimplementedError();

  @override
  Stream<BluetoothAdapterState> get state {
    return MergeStream<dynamic>([
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

  @override
  Future<void> stopScan() {
    // TODO: implement stopScan
    throw UnimplementedError();
  }
}
