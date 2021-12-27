part of vive_base_station_device_provider;

class ClearIdExtension extends DeviceExtension {
  ClearIdExtension(
      {required ViveBaseStationPersistence persistence,
      required LHDeviceIdentifier deviceId,
      required VoidCallback clearId})
      : super(
            toolTip: 'Clear id',
            icon: Text('ID'),
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
