import '../ble/BluetoothDevice.dart';
import '../deviceProviders/BLEDeviceProvider.dart';
import 'LighthouseBackEnd.dart';

///
/// A back end that will use [BLEDeviceProvider]s to provide [BLEDevice]s
///
abstract class BLELighthouseBackEnd
    extends LighthouseBackEnd<BLEDeviceProvider, LHBluetoothDevice> {}
