import 'package:flutter/foundation.dart';

import '../LighthouseDevice.dart';
import '../adapterState/AdapterState.dart';
import 'BLELighthouseBackEnd.dart';

/// A back end that provides devices using [Win32].
class Win32BackEnd extends BLELighthouseBackEnd {
  Win32BackEnd._();

  // Make sure there is always only one instance.
  static Win32BackEnd? _instance;

  static Win32BackEnd get instance {
    if (!kReleaseMode) {
      throw UnsupportedError("Win32 not supported for this platform");
    }
    return _instance ??= Win32BackEnd._();
  }

  @override
  Stream<LighthouseDevice?> get lighthouseStream =>
      throw UnsupportedError("BlueZ not  supported for this platform");

  @override
  Stream<BluetoothAdapterState> get state =>
      throw UnsupportedError("BlueZ not supported for this platform");

  @override
  Future<void> stopScan() {
    throw UnsupportedError("BlueZ not supported for this platform");
  }
}
