import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

class QuickBlueBackEnd extends BLELighthouseBackEnd {
  // Make sure there is always only one instance.
  static QuickBlueBackEnd? _instance;

  QuickBlueBackEnd._();

  static QuickBlueBackEnd get instance {
    assert(() {
      throw UnsupportedError("Quick blue not supported for this platform");
    }());
    return _instance ??= QuickBlueBackEnd._();
  }

  @override
  Stream<LighthouseDevice?> get lighthouseStream => throw UnsupportedError(
      "Flutter reactive ble not supported for this platform");

  @override
  Stream<BluetoothAdapterState> get state => throw UnsupportedError(
      "Flutter reactive ble not supported for this platform");

  @override
  Future<void> stopScan() {
    throw UnsupportedError(
        "Flutter reactive ble not supported for this platform");
  }
}
