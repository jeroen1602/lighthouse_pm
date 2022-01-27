import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/settings_dao.dart';
import 'package:lighthouse_pm/data/dao/vive_base_station_dao.dart';
import 'package:lighthouse_pm/data/database.dart';
import 'package:rxdart/rxdart.dart';

class FakeBloc extends Fake implements LighthousePMBloc {
  FakeBloc(this.internalSettingsDao, this.internalViveBaseStation);

  FakeBloc.normal()
      : internalSettingsDao = FakeSettingsDao(),
        internalViveBaseStation = FakeViveBaseStationDao();

  final FakeSettingsDao internalSettingsDao;
  final FakeViveBaseStationDao internalViveBaseStation;

  @override
  FakeSettingsDao get settings => internalSettingsDao;

  @override
  FakeViveBaseStationDao get viveBaseStation => internalViveBaseStation;
}

class FakeSettingsDao extends Fake implements SettingsDao {
  var shortcutEnabled = false;

  @override
  Stream<bool> getShortcutsEnabledStream() {
    return Stream.value(shortcutEnabled);
  }
}

class FakeViveBaseStationDao extends Fake implements ViveBaseStationDao {
  @override
  Future<int?> getId(final String deviceId) async {
    final stream = idsStream;
    if (stream == null) {
      return null;
    }
    return stream.valueOrNull
        ?.cast<ViveBaseStationId?>()
        .firstWhere((final element) => element?.deviceId == deviceId,
            orElse: () => null)
        ?.baseStationId;
  }

  BehaviorSubject<List<ViveBaseStationId>>? idsStream;

  @override
  Future<void> insertId(final String deviceId, final int id) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((final element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
      }
      idsStream.valueOrNull
          ?.add(ViveBaseStationId(deviceId: deviceId, baseStationId: id));
      idsStream.add(idsStream.valueOrNull ?? []);
    }
  }

  @override
  Future<void> deleteId(final String deviceId) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.valueOrNull
              ?.indexWhere((final element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.valueOrNull?.removeAt(index);
        idsStream.add(idsStream.valueOrNull ?? []);
      }
    }
  }

  @override
  Stream<List<ViveBaseStationId>> getViveBaseStationIdsAsStream() {
    startViveBaseStationIdsStream();
    return idsStream!.stream;
  }

  void startViveBaseStationIdsStream(
      [final List<ViveBaseStationId> data = const []]) {
    idsStream ??= BehaviorSubject.seeded(data.toList());
  }
}
