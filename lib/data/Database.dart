import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'dao/NicknameDao.dart';
import 'dao/SettingsDao.dart';
import 'dao/ViveBaseStationDao.dart';
import 'tables/LastSeenDevicesTable.dart';
import 'tables/NicknameTable.dart';
import 'tables/SimpleSettingsTable.dart';
import 'tables/ViveBaseStationIdTable.dart';

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

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [
  Nicknames,
  LastSeenDevices,
  SimpleSettings,
  ViveBaseStationIds,
], daos: [
  SettingsDao,
  NicknameDao,
  ViveBaseStationDao
])
class LighthouseDatabase extends _$LighthouseDatabase {
  LighthouseDatabase() : super(_openConnection());

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
