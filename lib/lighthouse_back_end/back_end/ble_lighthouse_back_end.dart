part of lighthouse_back_end;

///
/// A back end that will use [BLEDeviceProvider]s to provide [BLEDevice]s
///
abstract class BLELighthouseBackEnd
    extends LighthouseBackEnd<BLEDeviceProvider, LHBluetoothDevice> {}
