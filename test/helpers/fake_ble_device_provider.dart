import 'package:lighthouse_pm/lighthouse_provider/ble/bluetooth_device.dart';
import 'package:lighthouse_pm/lighthouse_provider/ble/guid.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_providers/ble_device_provider.dart';
import 'package:lighthouse_pm/lighthouse_provider/devices/ble_device.dart';

import 'fake_high_level_device.dart';

class FakeBLEDeviceProvider extends BLEDeviceProvider {
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return FakeHighLevelDevice(device);
  }

  @override
  String get namePrefix => "LHB-";

  /// Not needed
  @override
  List<LighthouseGuid> get characteristics => throw UnimplementedError();

  /// Not needed
  @override
  List<LighthouseGuid> get optionalServices => throw UnimplementedError();

  /// Not needed
  @override
  List<LighthouseGuid> get requiredServices => throw UnimplementedError();
}
