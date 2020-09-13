import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/NicknameTable.dart';

part 'Database.g.dart';

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

@UseMoor(tables: [Nicknames])
class LighthouseDatabase extends _$LighthouseDatabase {
  LighthouseDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<Nickname>> get watchSavedNicknames => select(nicknames).watch();

  Future<int> insertNewNickname(Nickname nickname) {
    return into(nicknames).insert(nickname, mode: InsertMode.insertOrReplace);
  }

  Future deleteNicknames(List<String> macAddresses) {
    return (delete(nicknames)..where((t) => t.macAddress.isIn(macAddresses)))
        .go();
  }
}
