import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:rxdart/rxdart.dart';

class FakePairBackEnd extends BLELighthouseBackEnd with PairBackEnd {
  final List<LHBluetoothDevice> devices;

  FakePairBackEnd(this.devices);

  final BehaviorSubject<LighthouseDevice?> _foundDeviceSubject =
      BehaviorSubject.seeded(null);

  @override
  Stream<LighthouseDevice?> get lighthouseStream => _foundDeviceSubject.stream;

  @override
  Future<void> stopScan() async {
    _foundDeviceSubject.add(null);
    _isScanningSubject.add(false);
  }

  @override
  Future<void> startScan(
      {required Duration timeout, required Duration? updateInterval}) async {
    await super.startScan(timeout: timeout, updateInterval: updateInterval);
    _isScanningSubject.add(true);
    for (final lowLevelDevice in devices) {
      final device = await getLighthouseDevice(lowLevelDevice);
      if (device != null) {
        _foundDeviceSubject.add(device);
      }
      await Future.delayed(Duration(milliseconds: 10));
    }
    _isScanningSubject.add(false);
  }

  final BehaviorSubject<bool> _isScanningSubject =
      BehaviorSubject.seeded(false);

  @override
  Stream<bool> get isScanning => _isScanningSubject.stream;

  @override
  Stream<BluetoothAdapterState> get state =>
      Stream.value(BluetoothAdapterState.on);

  @override
  Stream<int> numberOfPairedDevices() async* {
    yield 0;
  }

  @override
  Future<void> pairNewDevice(
      {required Duration timeout, required Duration? updateInterval}) {
    // TODO: implement pairNewDevice
    throw UnimplementedError();
  }
}
