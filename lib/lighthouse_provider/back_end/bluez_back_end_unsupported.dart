import 'package:flutter/foundation.dart';

import '../adapter_state/adapter_state.dart';
import '../lighthouse_device.dart';
import 'ble_lighthouse_back_end.dart';

/// A back end that provides devices using [BlueZClient].
class BlueZBackEnd extends BLELighthouseBackEnd {
  BlueZBackEnd._();

  // Make sure there is always only one instance.
  static BlueZBackEnd? _instance;

  static BlueZBackEnd get instance {
    if (!kReleaseMode) {
      throw UnsupportedError("BlueZ not supported for this platform");
    }
    return _instance ??= BlueZBackEnd._();
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
