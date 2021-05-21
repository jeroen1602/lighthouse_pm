import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

import '../../ble/BluetoothDevice.dart';
import '../../ble/BluetoothService.dart';
import '../../ble/DeviceIdentifier.dart';
import '../../ble/Guid.dart';
import 'FlutterWebBluetoothService.dart';

class FlutterWebBluetoothDevice extends LHBluetoothDevice {
  FlutterWebBluetoothDevice(this.device, this.characteristicsGuid);

  final BluetoothDevice device;
  final List<LighthouseGuid> characteristicsGuid;

  @override
  Future<void> connect({Duration? timeout}) async {
    await device.connect(timeout: timeout);
  }

  @override
  Future<void> disconnect() async {
    return device.disconnect();
  }

  @override
  Future<List<LHBluetoothService>> discoverServices() async {
    final discoveredServices = await device.discoverServices();
    final List<LHBluetoothService> services = [];
    for (final discoveredService in discoveredServices) {
      final service = await FlutterWebBluetoothService.withCharacteristics(
          discoveredService, characteristicsGuid);
      services.add(service);
    }
    return services;
  }

  @override
  LHDeviceIdentifier get id => LHDeviceIdentifier(this.device.id);

  @override
  String get name => this.device.name ?? '';

  @override
  Stream<LHBluetoothDeviceState> get state =>
      this.device.connected.map((connected) => connected
          ? LHBluetoothDeviceState.connected
          : LHBluetoothDeviceState.disconnected);
}
