import '../ble/BluetoothDevice.dart';
import '../deviceProviders/BLEDeviceProvider.dart';
import 'LighthouseBackend.dart';

///
/// A backend that will use [BLEDeviceProvider]s to provide [BLEDevice]s
///
abstract class BLELighthouseBackend
    extends LighthouseBackend<BLEDeviceProvider, LHBluetoothDevice> {}
