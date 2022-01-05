library vive_base_station_device_provider;

import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:flutter_web_bluetooth/flutter_web_bluetooth.dart';
import 'package:lighthouse_pm/lighthouse_back_end/lighthouse_back_end.dart';
import 'package:lighthouse_pm/lighthouse_provider/device_extensions/device_extension.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';
import 'package:rxdart/rxdart.dart';

part 'vive_base_station/device/vive_base_station_device.dart';

part 'vive_base_station/specific_extensions/clear_id_extension.dart';

part 'vive_base_station/vive_base_station_persistence.dart';

typedef RequestPairId<C> = Future<String?> Function(
    C? context, int? pairIdHint);

///
/// A device provider for discovering and connection to [LighthouseV2Device]s.
///
class ViveBaseStationDeviceProvider
    extends BLEDeviceProvider<ViveBaseStationPersistence> {
  ViveBaseStationDeviceProvider._();

  static ViveBaseStationDeviceProvider? _instance;

  ///
  /// Get the instance of this [DeviceProvider].
  ///
  static ViveBaseStationDeviceProvider get instance {
    return _instance ??= ViveBaseStationDeviceProvider._();
  }

  ///
  /// Returns a new instance of a [LighthouseV2Device].
  ///
  @override
  Future<BLEDevice> internalGetDevice(LHBluetoothDevice device) async {
    return ViveBaseStationDevice(
        device, requirePersistence(), _requestCallback);
  }

  RequestPairId<dynamic>? _requestCallback;

  void setRequestPairIdCallback<C>(RequestPairId<C> method) {
    _requestCallback = (dynamic context, int? pairIdHint) {
      return method(context, pairIdHint);
    };
  }

  @override
  List<LighthouseGuid> get characteristics => [
        LighthouseGuid.fromString(
            ViveBaseStationDevice.powerCharacteristicUUID),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.manufacturerNameString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.modelNumberString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.serialNumberString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.hardwareRevisionString.uuid),
        LighthouseGuid.fromString(
            BluetoothDefaultCharacteristicUUIDS.firmwareRevisionString.uuid),
      ];

  @override
  List<LighthouseGuid> get optionalServices => [
        LighthouseGuid.fromString(
            BluetoothDefaultServiceUUIDS.deviceInformation.uuid),
      ];

  @override
  List<LighthouseGuid> get requiredServices => [
        LighthouseGuid.fromString(ViveBaseStationDevice.powerServiceUUID),
      ];

  @override
  String get namePrefix => "HTC BS";
}
