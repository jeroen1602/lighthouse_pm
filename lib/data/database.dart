import 'package:drift/drift.dart';

import 'dao/group_dao.dart';
import 'dao/nickname_dao.dart';
import 'dao/settings_dao.dart';
import 'dao/vive_base_station_dao.dart';
import 'tables/group_table.dart';
import 'tables/last_seen_devices_table.dart';
import 'tables/nickname_table.dart';
import 'tables/simple_settings_table.dart';
import 'tables/vive_base_station_id_table.dart';

export 'shared/shared.dart';

part 'database.g.dart';

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
  LighthouseDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (final Migrator m) {
        return m.createAll();
      }, onUpgrade: (final Migrator m, final int from, final int to) async {
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
            await transaction(() async {
              await customStatement('PRAGMA foreign_keys = OFF');
              // groups table already exists so we need to rename, otherwise it will be created
              await m.renameColumn(
                  groupEntries, 'mac_address', groupEntries.deviceId);
              // Update the references, since the newer version of drift already supports foreign keys
              await m.alterTable(TableMigration(groupEntries));
              // Older versions of drift named it `"groups"` while newer versions are able to handle `groups`
              await m.renameTable(groups, '""groups""');
              await customStatement('PRAGMA foreign_keys = ON');
            });
          }
          await m.deleteTable('vive_base_station_ids');
          await m.createTable(viveBaseStationIds);
        }
      }, beforeOpen: (final details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      });
}
