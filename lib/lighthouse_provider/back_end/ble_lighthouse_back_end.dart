import '../ble/bluetooth_device.dart';
import '../device_providers/ble_device_provider.dart';
import 'lighthouse_back_end.dart';

///
/// A back end that will use [BLEDeviceProvider]s to provide [BLEDevice]s
///
abstract class BLELighthouseBackEnd
    extends LighthouseBackEnd<BLEDeviceProvider, LHBluetoothDevice> {}
