part of vive_base_station_device_provider;

abstract class ViveBaseStationPersistence {
  Future<int?> getId(LHDeviceIdentifier deviceId);

  Future<void> deleteId(LHDeviceIdentifier deviceId);

  Future<void> insertId(LHDeviceIdentifier deviceId, int id);

  Stream<bool> hasIdStored(LHDeviceIdentifier deviceId);
}
