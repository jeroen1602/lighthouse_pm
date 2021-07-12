import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

import '../../ble/BluetoothDevice.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/DeviceIdentifier.dart';
import 'BlueZBluetoothService.dart';

class BlueZBluetoothDevice extends LHBluetoothDevice {
  BlueZBluetoothDevice(this.device) {
    _stateSubject.onCancel = () {
      _stateStream?.cancel();
      _stateStream = null;
    };
  }

  final BlueZDevice device;

  @override
  Future<void> connect({Duration? timeout}) async {
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
    return device.gattServices.map((e) => BlueZBluetoothService(e)).toList();
  }

  @override
  LHDeviceIdentifier get id => LHDeviceIdentifier(device.address);

  @override
  String get name => device.name;

  BehaviorSubject<LHBluetoothDeviceState> _stateSubject = BehaviorSubject();
  StreamSubscription<LHBluetoothDeviceState>? _stateStream;

  void _startStateStream() {
    if (_stateStream == null) {
      _stateStream = MergeStream(
              [Stream.value(null), Stream.periodic(Duration(seconds: 2))])
          .map((event) => device.connected)
          .map((event) => event
              ? LHBluetoothDeviceState.connected
              : LHBluetoothDeviceState.disconnected)
          .listen((event) {
        _stateSubject.add(event);
      });
    }
  }

  @override
  Stream<LHBluetoothDeviceState> get state {
    _startStateStream();
    return _stateSubject.stream;
  }
}
