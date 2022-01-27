import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/vive_base_station_device_provider.dart';

class ViveBaseStationBloc implements ViveBaseStationPersistence {
  ViveBaseStationBloc(this.bloc);

  final LighthousePMBloc bloc;

  @override
  Future<void> deleteId(LHDeviceIdentifier deviceId) {
    return bloc.viveBaseStation.deleteId(deviceId.toString());
  }

  @override
  Future<int?> getId(LHDeviceIdentifier deviceId) {
    return bloc.viveBaseStation.getId(deviceId.toString());
  }

  @override
  Stream<bool> hasIdStored(LHDeviceIdentifier deviceId) {
    final deviceIdString = deviceId.toString();
    return bloc.viveBaseStation.getViveBaseStationIdsAsStream().map((ids) {
      return (ids.indexWhere((element) => element.deviceId == deviceIdString) >=
          0);
    });
  }

  @override
  Future<void> insertId(LHDeviceIdentifier deviceId, int id) {
    return bloc.viveBaseStation.insertId(deviceId.toString(), id);
  }
}
