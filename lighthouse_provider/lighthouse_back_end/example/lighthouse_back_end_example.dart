import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';

class ExampleBackEnd extends LighthouseBackEnd {
  static ExampleBackEnd? _instance;

  ExampleBackEnd._();

  static ExampleBackEnd get instance {
    return _instance ??= ExampleBackEnd._();
  }

  ///
  /// A stream that should publish all the new lighthouses found one after
  /// the other.
  ///
  @override
  Stream<LighthouseDevice?> get lighthouseStream => Stream.value(null);

  ///
  /// A stream with the state of the adapter.
  ///
  @override
  Stream<BluetoothAdapterState> get state =>
      Stream.value(BluetoothAdapterState.on);

  ///
  /// Stop scanning.
  ///
  @override
  Future<void> stopScan() {
    throw UnimplementedError("Do some stop scanning");
  }

  ///
  /// Start scanning for devices.
  ///
  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    throw UnsupportedError("Do some start scanning");
  }
}

void main() {
  final instance = ExampleBackEnd.instance;

  final provider = LighthouseProvider.instance;
  provider.addBackEnd(instance);

  // Add a provider here
  //provider.addProvider()

  provider.startScan(timeout: Duration(seconds: 5));
}
