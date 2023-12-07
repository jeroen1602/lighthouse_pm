part of '../../vive_base_station_device_provider.dart';

abstract class ViveBaseStationPersistence {
  Future<int?> getId(final LHDeviceIdentifier deviceId);

  Future<void> deleteId(final LHDeviceIdentifier deviceId);

  Future<void> insertId(final LHDeviceIdentifier deviceId, final int id);

  Stream<bool> hasIdStored(final LHDeviceIdentifier deviceId);
}
