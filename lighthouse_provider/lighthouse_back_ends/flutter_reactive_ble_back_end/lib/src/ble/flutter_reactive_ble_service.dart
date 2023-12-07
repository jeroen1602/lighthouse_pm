part of '../flutter_reactive_ble_io.dart';

class FlutterReactiveBleService extends LHBluetoothService {
  FlutterReactiveBleService(
      final String deviceId, final Service discoveredService)
      : uuid = LighthouseGuid.fromString(discoveredService.id.toString()),
        characteristics =
            discoveredService.characteristics.map((final characteristic) {
          return FlutterReactiveBleCharacteristic(deviceId, characteristic);
        }).toList();

  @override
  final LighthouseGuid uuid;
  @override
  final List<LHBluetoothCharacteristic> characteristics;
}
