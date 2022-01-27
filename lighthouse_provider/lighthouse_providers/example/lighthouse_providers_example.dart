import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

class ExampleLighthouseV2Persistence extends LighthouseV2Persistence {
  @override
  Future<bool> areShortcutsEnabled() {
    throw UnimplementedError();
  }
}

void setupLighthouseV2DeviceProvider() {
  final instance = LighthouseV2DeviceProvider.instance;

  instance.setPersistence(ExampleLighthouseV2Persistence());
}

class ExampleViveBaseStationPersistence extends ViveBaseStationPersistence {
  @override
  Future<void> deleteId(LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<int?> getId(LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Stream<bool> hasIdStored(LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<void> insertId(LHDeviceIdentifier deviceId, int id) {
    throw UnimplementedError();
  }
}

void setupViveBaseStationDeviceProvider() {
  final instance = ViveBaseStationDeviceProvider.instance;

  instance.setPersistence(ExampleViveBaseStationPersistence());
  instance.setRequestPairIdCallback((context, pairIdHint) async {
    return "PAIR_ID_FOR_DEVICE";
  });
}

void main() {
  final provider = LighthouseProvider.instance;

  // Add  a back end.
  // provider.addBackEnd();

  setupLighthouseV2DeviceProvider();
  provider.addProvider(LighthouseV2DeviceProvider.instance);

  setupViveBaseStationDeviceProvider();
  provider.addProvider(ViveBaseStationDeviceProvider.instance);

  provider.startScan(timeout: Duration(seconds: 5));
}
