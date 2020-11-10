import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor_flutter/moor_flutter.dart';

class NicknameBloc {
  final LighthouseDatabase db;

  NicknameBloc(this.db);

  Stream<List<Nickname>> get watchSavedNicknames =>
      db.select(db.nicknames).watch();

  Stream<Nickname /* ? */> watchNicknameForMacAddress(String macAddress) {
    macAddress = macAddress.toUpperCase();
    return (db.select(db.nicknames)..where((n) => n.macAddress.equals(macAddress)))
        .watch()
        .map((list) {
       if (list.isEmpty) {
         return null;
       }
       return list[0];
    });
  }

  Future<int> insertNickname(Nickname nickname) {
    return db
        .into(db.nicknames)
        .insert(nickname, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteNicknames(List<String> macAddresses) {
    return (db.delete(db.nicknames)
          ..where((t) => t.macAddress.isIn(macAddresses)))
        .go();
  }

  Future<int> insertLastSeenDevice(LastSeenDevice lastSeen) {
    return db.into(db.lastSeenDevices)
        .insert(lastSeen, mode: InsertMode.insertOrReplace);
  }

  Stream<List<LastSeenDevice>> get watchLastSeenDevices =>
      db.select(db.lastSeenDevices).watch();

  Stream<List<NicknamesLastSeenJoin>> watchSavedNicknamesWithLastSeen() {
    final query = db.select(db.nicknames).join([
      leftOuterJoin(db.lastSeenDevices,
          db.lastSeenDevices.macAddress.equalsExp(db.nicknames.macAddress))
    ]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return NicknamesLastSeenJoin(row.read(db.nicknames.macAddress),
            row.read(db.nicknames.nickname), row.read(db.lastSeenDevices.lastSeen));
      }).toList();
    });
  }

  Future<void> deleteAllLastSeen() {
    return db.delete(db.lastSeenDevices).go();
  }

}
