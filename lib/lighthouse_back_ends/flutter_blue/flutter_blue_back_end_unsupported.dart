import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';

/// A back end that provides devices using [FlutterBlue].
class FlutterBlueLighthouseBackEnd extends BLELighthouseBackEnd {
  FlutterBlueLighthouseBackEnd._();

  // Make sure there is always only one instance.
  static FlutterBlueLighthouseBackEnd? _instance;

  static FlutterBlueLighthouseBackEnd get instance {
    if (!kReleaseMode) {
      throw UnsupportedError("Flutter blue not supported for this platform");
    }
    return _instance ??= FlutterBlueLighthouseBackEnd._();
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
