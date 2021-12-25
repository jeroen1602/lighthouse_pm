import 'package:drift/drift.dart';

import 'dao/GroupDao.dart';
import 'dao/NicknameDao.dart';
import 'dao/SettingsDao.dart';
import 'dao/ViveBaseStationDao.dart';
import 'tables/GroupTable.dart';
import 'tables/LastSeenDevicesTable.dart';
import 'tables/NicknameTable.dart';
import 'tables/SimpleSettingsTable.dart';
import 'tables/ViveBaseStationIdTable.dart';

export 'shared/shared.dart';

part 'Database.g.dart';

// This file required generated files.
// Use `flutter packages pub run build_runner build`
// or `flutter packages pub run build_runner watch` to generate these files.

@DriftDatabase(tables: [
  Nicknames,
  LastSeenDevices,
  SimpleSettings,
  ViveBaseStationIds,
  Groups,
  GroupEntries,
], daos: [
  NicknameDao,
  SettingsDao,
  ViveBaseStationDao,
  GroupDao,
])
class LighthouseDatabase extends _$LighthouseDatabase {
  LighthouseDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1 && (to >= 2 && to <= 4)) {
          await m.renameColumn(simpleSettings, 'id', simpleSettings.settingsId);
        }
        if ((from >= 1 && from <= 2) && (to >= 3 && to <= 4)) {
          await m.createTable(groups);
          await m.createTable(groupEntries);
        }
        if ((from >= 1 && from <= 3) && (to == 4)) {
          await m.renameColumn(nicknames, 'mac_address', nicknames.deviceId);
          await m.renameColumn(
              lastSeenDevices, 'mac_address', lastSeenDevices.deviceId);
          if (from >= 3 && from <= 3) {
            // groups table already exists so we need to rename, otherwise it will be created
            await m.renameColumn(
                groupEntries, 'mac_address', groupEntries.deviceId);
          }
          await m.deleteTable('vive_base_station_ids');
          await m.createTable(viveBaseStationIds);
        }
      }, beforeOpen: (details) async {
        await this.customStatement('PRAGMA foreign_keys = ON');
      });
}
