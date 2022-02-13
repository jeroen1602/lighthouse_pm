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
  Future<void> deleteId(final LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<int?> getId(final LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Stream<bool> hasIdStored(final LHDeviceIdentifier deviceId) {
    throw UnimplementedError();
  }

  @override
  Future<void> insertId(final LHDeviceIdentifier deviceId, final int id) {
    throw UnimplementedError();
  }
}

void setupViveBaseStationDeviceProvider() {
  final instance = ViveBaseStationDeviceProvider.instance;

  instance.setPersistence(ExampleViveBaseStationPersistence());
  instance.setRequestPairIdCallback((final context, final pairIdHint) async {
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
