import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

enum LighthouseProviders {
  lighthouseV2("Lighthouse v2"),
  viveBaseStation("Vive base station");

  final String name;

  BLEDeviceProvider get provider {
    switch (this) {
      case lighthouseV2:
        return LighthouseV2DeviceProvider.instance;
      case viveBaseStation:
        return ViveBaseStationDeviceProvider.instance;
    }
  }

  const LighthouseProviders(this.name);
}
