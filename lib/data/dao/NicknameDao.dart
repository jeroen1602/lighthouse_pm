import 'package:moor/moor.dart';

import '../Database.dart';
import '../tables/LastSeenDevicesTable.dart';
import '../tables/NicknameTable.dart';

part 'NicknameDao.g.dart';

@UseDao(tables: [Nicknames, LastSeenDevices])
class NicknameDao extends DatabaseAccessor<LighthouseDatabase>
    with _$NicknameDaoMixin {
  NicknameDao(LighthouseDatabase attachedDatabase) : super(attachedDatabase);

  Stream<List<Nickname>> get watchSavedNicknames => select(nicknames).watch();

  Stream<Nickname?> watchNicknameForMacAddress(String macAddress) {
    macAddress = macAddress.toUpperCase();
    return (select(nicknames)..where((n) => n.macAddress.equals(macAddress)))
        .watch()
        .map((list) {
      if (list.isEmpty) {
        return null;
      }
      return list[0];
    });
  }

  Future<int> insertNickname(Nickname nickname) {
    return into(nicknames).insert(nickname, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteNicknames(List<String> macAddresses) {
    return (delete(nicknames)..where((t) => t.macAddress.isIn(macAddresses)))
        .go();
  }

  Future<int> insertLastSeenDevice(LastSeenDevicesCompanion lastSeen) {
    return into(lastSeenDevices)
        .insert(lastSeen, mode: InsertMode.insertOrReplace);
  }

  Stream<List<LastSeenDevice>> get watchLastSeenDevices =>
      select(lastSeenDevices).watch();

  Stream<List<NicknamesLastSeenJoin>> watchSavedNicknamesWithLastSeen() {
    final query = select(nicknames).join([
      leftOuterJoin(lastSeenDevices,
          lastSeenDevices.macAddress.equalsExp(nicknames.macAddress))
    ]);
    return query.watch().map((rows) {
      return rows.map((row) {
        return NicknamesLastSeenJoin(row.read(nicknames.macAddress)!,
            row.read(nicknames.nickname)!, row.read(lastSeenDevices.lastSeen));
      }).toList();
    });
  }

  Future<void> deleteAllLastSeen() {
    return delete(lastSeenDevices).go();
  }
}
