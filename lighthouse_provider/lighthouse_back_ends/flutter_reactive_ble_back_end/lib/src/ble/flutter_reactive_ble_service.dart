part of flutter_reactive_ble_back_end;

class FlutterReactiveBleService extends LHBluetoothService {
  FlutterReactiveBleService(
      final String deviceId, final DiscoveredService discoveredService)
      : uuid =
            LighthouseGuid.fromString(discoveredService.serviceId.toString()),
        characteristics =
            discoveredService.characteristics.map((final characteristic) {
          return FlutterReactiveBleCharacteristic(deviceId, characteristic);
        }).toList();

  @override
  final LighthouseGuid uuid;
  @override
  final List<LHBluetoothCharacteristic> characteristics;
}
