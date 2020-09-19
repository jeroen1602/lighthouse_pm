import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/LastSeenDevicesTable.dart';
import 'tables/NicknameTable.dart';

part 'Database.g.dart';

class NicknamesLastSeenJoin {
  NicknamesLastSeenJoin(this.macAddress, this.nickname, this.lastSeen);

  final String macAddress;
  final String nickname;
  final DateTime /* ? */ lastSeen;
}

// This file required generated files. Use `flutter packages pub run build_runner
// build` or `flutter packages pub run build_runner watch` to generate these files.

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

@UseMoor(tables: [Nicknames, LastSeenDevices])
class LighthouseDatabase extends _$LighthouseDatabase {
  LighthouseDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<Nickname /* ? */> watchNicknameForMacAddress(String macAddress) {
    macAddress = macAddress.toUpperCase();
    return (select(nicknames)..where((n) => n.macAddress.equals(macAddress))).watch().map((list) {
      if (list.isEmpty) {
        return null;
      }
      return list[0];
    });
  }

  Stream<List<Nickname>> get watchSavedNicknames => select(nicknames).watch();

  Future<int> insertNewNickname(Nickname nickname) {
    return into(nicknames).insert(nickname, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteNicknames(List<String> macAddresses) {
    return (delete(nicknames)..where((t) => t.macAddress.isIn(macAddresses)))
        .go();
  }

  Future<int> insertLastSeenDevice(LastSeenDevice lastSeen) {
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
        return NicknamesLastSeenJoin(row.read(nicknames.macAddress),
            row.read(nicknames.nickname), row.read(lastSeenDevices.lastSeen));
      }).toList();
    });
  }

  Future<void> deleteAllLastSeen() {
    return delete(lastSeenDevices).go();
  }
}
