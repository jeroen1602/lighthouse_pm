part of '../bluez_back_end_io.dart';

class BlueZBluetoothDevice extends LHBluetoothDevice {
  BlueZBluetoothDevice(this.device) {
    _stateSubject.onCancel = () {
      _stateStream?.cancel();
      _stateStream = null;
    };
  }

  final BlueZDevice device;

  @override
  Future<void> connect({final Duration? timeout}) async {
    if (timeout != null) {
      await device.connect().timeout(timeout);
    } else {
      await device.connect();
    }
  }

  @override
  Future<void> disconnect() async {
    await device.disconnect();
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    return device.gattServices
        .map((final e) => BlueZBluetoothService(e))
        .toList();
  }

  @override
  LHDeviceIdentifier get id => LHDeviceIdentifier(device.address);

  @override
  String get name => device.name;

  final BehaviorSubject<LHBluetoothDeviceState> _stateSubject =
      BehaviorSubject();
  StreamSubscription<LHBluetoothDeviceState>? _stateStream;

  void _startStateStream() {
    _stateStream ??=
        MergeStream([Stream.value(null), Stream.periodic(Duration(seconds: 2))])
            .map((final event) => device.connected)
            .map((final event) => event
                ? LHBluetoothDeviceState.connected
                : LHBluetoothDeviceState.disconnected)
            .listen((final event) {
      _stateSubject.add(event);
    });
  }

  @override
  Stream<LHBluetoothDeviceState> get state {
    _startStateStream();
    return _stateSubject.stream;
  }
}
