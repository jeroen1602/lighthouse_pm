import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/last_seen_devices_table.dart';
import '../tables/nickname_table.dart';

part 'nickname_dao.g.dart';

@DriftAccessor(tables: [Nicknames, LastSeenDevices])
class NicknameDao extends DatabaseAccessor<LighthouseDatabase>
    with _$NicknameDaoMixin {
  NicknameDao(super.attachedDatabase);

  Stream<List<Nickname>> get watchSavedNicknames => select(nicknames).watch();

  Stream<Nickname?> watchNicknameForDeviceIds(String deviceId) {
    deviceId = deviceId.toUpperCase();
    return (select(nicknames)..where((final n) => n.deviceId.equals(deviceId)))
        .watch()
        .map((final list) {
          if (list.isEmpty) {
            return null;
          }
          return list[0];
        });
  }

  Future<int> insertNickname(final Nickname nickname) {
    return into(nicknames).insert(nickname, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteNicknames(final List<String> deviceIds) {
    return (delete(
      nicknames,
    )..where((final t) => t.deviceId.isIn(deviceIds))).go();
  }

  Future<int> insertLastSeenDevice(final LastSeenDevicesCompanion lastSeen) {
    return into(
      lastSeenDevices,
    ).insert(lastSeen, mode: InsertMode.insertOrReplace);
  }

  Stream<List<LastSeenDevice>> get watchLastSeenDevices =>
      select(lastSeenDevices).watch();

  Stream<List<Nickname>> get watchNicknames => select(nicknames).watch();

  Stream<List<NicknamesLastSeenJoin>> watchSavedNicknamesWithLastSeen() {
    final query = select(nicknames).join([
      leftOuterJoin(
        lastSeenDevices,
        lastSeenDevices.deviceId.equalsExp(nicknames.deviceId),
      ),
    ]);
    return query.watch().map((final rows) {
      return rows.map((final row) {
        return NicknamesLastSeenJoin(
          row.read(nicknames.deviceId)!,
          row.read(nicknames.nickname)!,
          row.read(lastSeenDevices.lastSeen),
        );
      }).toList();
    });
  }

  Future<void> deleteAllLastSeen() {
    return delete(lastSeenDevices).go();
  }

  Future<void> deleteLastSeen(final LastSeenDevice lastSeen) {
    return (delete(
      lastSeenDevices,
    )..where((final tbl) => tbl.deviceId.equals(lastSeen.deviceId))).go();
  }
}
