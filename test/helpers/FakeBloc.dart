import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/Database.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';
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
  Future<int?> getId(String deviceId) async {
    final stream = idsStream;
    if (stream == null) {
      return null;
    }
    return stream.value
        ?.cast<ViveBaseStationId?>()
        .firstWhere((element) => element?.deviceId == deviceId,
            orElse: () => null)
        ?.baseStationId;
  }

  BehaviorSubject<List<ViveBaseStationId>>? idsStream;

  @override
  Future<void> insertId(String deviceId, int id) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.value
              ?.indexWhere((element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.value?.removeAt(index);
      }
      idsStream.value
          ?.add(ViveBaseStationId(deviceId: deviceId, baseStationId: id));
      idsStream.add(idsStream.value ?? []);
    }
  }

  @override
  Future<void> deleteId(String deviceId) async {
    final idsStream = this.idsStream;
    if (idsStream != null) {
      final index = idsStream.value
              ?.indexWhere((element) => element.deviceId == deviceId) ??
          -1;
      if (index >= 0) {
        idsStream.value?.removeAt(index);
        idsStream.add(idsStream.value ?? []);
      }
    }
  }

  @override
  Stream<List<ViveBaseStationId>> getViveBaseStationIdsAsStream() {
    startViveBaseStationIdsStream();
    return idsStream!.stream;
  }

  void startViveBaseStationIdsStream(
      [List<ViveBaseStationId> data = const []]) {
    if (idsStream == null) {
      idsStream = BehaviorSubject.seeded(data.toList());
    }
  }
}
