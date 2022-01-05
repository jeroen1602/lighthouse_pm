part of vive_base_station_device_provider;

typedef ClearIdCallback = Function();

class ClearIdExtension extends DeviceExtension {
  ClearIdExtension(
      {required ViveBaseStationPersistence persistence,
      required LHDeviceIdentifier deviceId,
      required ClearIdCallback clearId})
      : super(
            toolTip: 'Clear id',
            updateListAfter: true,
            onTap: () async {
              await persistence.deleteId(deviceId);
              clearId();
            }) {
    streamEnabledFunction = () {
      return persistence.hasIdStored(deviceId);
    };
  }
}
