import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';

import '../../ble/bluetooth_device.dart';
import '../../ble/bluetooth_service.dart';
import '../../ble/device_identifier.dart';
import '../../ble/guid.dart';
import 'flutter_web_bluetooth_service.dart';

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
  LHDeviceIdentifier get id => LHDeviceIdentifier(device.id);

  @override
  String get name => device.name ?? '';

  @override
  Stream<LHBluetoothDeviceState> get state =>
      device.connected.map((connected) => connected
          ? LHBluetoothDeviceState.connected
          : LHBluetoothDeviceState.disconnected);
}
