import 'package:flutter/foundation.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import 'BLELighthouseBackEnd.dart';

/// A back end that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackEnd extends BLELighthouseBackEnd {
  FlutterBlueLighthouseBackEnd._();

  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackEnd? _instance;

  static FlutterBlueLighthouseBackEnd get instance {
    if (!kReleaseMode) {
      throw UnsupportedError("Flutter blue not supported for this platform");
    }
    if (_instance == null) {
      _instance = FlutterBlueLighthouseBackEnd._();
    }
    return _instance!;
  }

  @override
  Stream<LighthouseDevice?> get lighthouseStream =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  Stream<BluetoothAdapterState> get state =>
      throw UnsupportedError("Flutter blue not supported for this platform");

  @override
  Future<void> stopScan() {
    throw UnsupportedError("Flutter blue not supported for this platform");
  }
}
