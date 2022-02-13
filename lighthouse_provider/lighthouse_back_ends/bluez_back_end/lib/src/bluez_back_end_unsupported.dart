import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

/// A back end that provides devices using [BlueZClient].
class BlueZBackEnd extends BLELighthouseBackEnd {
  BlueZBackEnd._();

  // Make sure there is always only one instance.
  static BlueZBackEnd? _instance;

  static BlueZBackEnd get instance {
    assert(() {
      throw UnsupportedError("BlueZ not supported for this platform");
    }());
    return _instance ??= BlueZBackEnd._();
  }

  @override
  Stream<LighthouseDevice?> get lighthouseStream =>
      throw UnsupportedError("BlueZ not supported for this platform");

  @override
  Stream<BluetoothAdapterState> get state =>
      throw UnsupportedError("BlueZ not supported for this platform");

  @override
  Future<void> stopScan() {
    throw UnsupportedError("BlueZ not supported for this platform");
  }
}
