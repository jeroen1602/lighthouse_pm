import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse_pm/bloc.dart';
import 'package:lighthouse_pm/data/dao/SettingsDao.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';

class FakeBloc extends Fake implements LighthousePMBloc {
  FakeBloc(this.internalSettingsDao, this.internalViveBaseStation);

  FakeBloc.normal()
      : internalSettingsDao = FakeSettingsDao(),
        internalViveBaseStation = FakeViveBaseStationDao();

  final FakeSettingsDao internalSettingsDao;
  final FakeViveBaseStationDao internalViveBaseStation;

  @override
  SettingsDao get settings => internalSettingsDao;

  @override
  ViveBaseStationDao get viveBaseStation => internalViveBaseStation;
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
    return null;
  }
}
