import 'package:lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:meta/meta.dart';

import 'fake_high_level_device.dart';

@visibleForTesting
class FakeBLEDeviceProvider extends BLEDeviceProvider {
  @override
  Future<BLEDevice> internalGetDevice(final LHBluetoothDevice device) async {
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
