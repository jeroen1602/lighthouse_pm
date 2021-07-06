import 'package:lighthouse_pm/lighthouseProvider/ble/BluetoothDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/Guid.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceProviders/BLEDeviceProvider.dart';
import 'package:lighthouse_pm/lighthouseProvider/devices/BLEDevice.dart';

import 'FakeHighLevelDevice.dart';

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
