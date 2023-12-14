import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

/// A back end that provides devices using [FlutterBluePlus].
class FlutterBluePlusLighthouseBackEnd extends BLELighthouseBackEnd {
  FlutterBluePlusLighthouseBackEnd._();

  // Make sure there is always only one instance.
  static FlutterBluePlusLighthouseBackEnd? _instance;

  static FlutterBluePlusLighthouseBackEnd get instance {
    assert(() {
      throw UnsupportedError(
          "Flutter blue plus is not supported for this platform");
    }());
    return _instance ??= FlutterBluePlusLighthouseBackEnd._();
  }

  @override
  Stream<LighthouseDevice?> get lighthouseStream => throw UnsupportedError(
      "Flutter blue plus is not supported for this platform");

  @override
  Stream<BluetoothAdapterState> get state => throw UnsupportedError(
      "Flutter blue plus is not supported for this platform");

  @override
  Future<void> stopScan() {
    throw UnsupportedError(
        "Flutter blue plus is not supported for this platform");
  }

  @override
  String get backendName => "FlutterBlueBackEndUnsupported";
}
