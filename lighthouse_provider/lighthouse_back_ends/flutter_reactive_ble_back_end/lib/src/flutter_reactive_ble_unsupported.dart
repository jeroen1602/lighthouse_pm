import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

class FlutterReactiveBleBackEnd extends BLELighthouseBackEnd {
  FlutterReactiveBleBackEnd._();

  // Make sure there is always only one instance.
  static FlutterReactiveBleBackEnd? _instance;

  static FlutterReactiveBleBackEnd get instance {
    assert(() {
      throw UnsupportedError(
          "Flutter reactive ble not supported for this platform");
    }());
    return _instance ??= FlutterReactiveBleBackEnd._();
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
