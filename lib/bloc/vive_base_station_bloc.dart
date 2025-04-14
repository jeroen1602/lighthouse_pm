import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

class ViveBaseStationBloc implements ViveBaseStationPersistence {
  ViveBaseStationBloc(this.bloc);

  final LighthousePMBloc bloc;

  @override
  Future<void> deleteId(final LHDeviceIdentifier deviceId) {
    return bloc.viveBaseStation.deleteId(deviceId.toString());
  }

  @override
  Future<int?> getId(final LHDeviceIdentifier deviceId) {
    return bloc.viveBaseStation.getId(deviceId.toString());
  }

  @override
  Stream<bool> hasIdStored(final LHDeviceIdentifier deviceId) {
    final deviceIdString = deviceId.toString();
    return bloc.viveBaseStation.getViveBaseStationIdsAsStream().map((
      final ids,
    ) {
      return (ids.indexWhere(
            (final element) => element.deviceId == deviceIdString,
          ) >=
          0);
    });
  }

  @override
  Future<void> insertId(final LHDeviceIdentifier deviceId, final int id) {
    return bloc.viveBaseStation.insertId(deviceId.toString(), id);
  }
}
