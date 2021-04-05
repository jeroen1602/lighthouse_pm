import 'package:moor/moor.dart';

import 'dao/NicknameDao.dart';
import 'dao/SettingsDao.dart';
import 'dao/ViveBaseStationDao.dart';
import 'tables/LastSeenDevicesTable.dart';
import 'tables/NicknameTable.dart';
import 'tables/SimpleSettingsTable.dart';
import 'tables/ViveBaseStationIdTable.dart';

export 'shared/shared.dart';

part 'Database.g.dart';

class NicknamesLastSeenJoin {
  NicknamesLastSeenJoin(this.macAddress, this.nickname, this.lastSeen);

  final String macAddress;
  final String nickname;
  final DateTime? lastSeen;
}

// This file required generated files.
// Use `flutter packages pub run build_runner build`
// or `flutter packages pub run build_runner watch` to generate these files.

@UseMoor(tables: [
  Nicknames,
  LastSeenDevices,
  SimpleSettings,
  ViveBaseStationIds,
], daos: [
  NicknameDao,
  SettingsDao,
  ViveBaseStationDao
])
class LighthouseDatabase extends _$LighthouseDatabase {
  LighthouseDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && to == 2) {
          await m.renameColumn(simpleSettings, 'id', simpleSettings.settingsId);
        }
      });
}
