import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';

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
