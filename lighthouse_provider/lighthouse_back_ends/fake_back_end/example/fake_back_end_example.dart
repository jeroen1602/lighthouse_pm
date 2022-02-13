import 'package:fake_back_end/fake_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

void main() {
  final instance = FakeBLEBackEnd.instance;
  // Add this backend to the lighthouse provider to start using it.
  final provider = LighthouseProvider.instance;
  provider.addBackEnd(instance);

  provider.addProvider(LighthouseV2DeviceProvider.instance);
  provider.addProvider(ViveBaseStationDeviceProvider.instance);

  provider.startScan(timeout: Duration(seconds: 5));
}
