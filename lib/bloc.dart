import 'package:lighthouse_pm/data/Database.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;

  LighthousePMBloc() : db = LighthouseDatabase();

  Stream<List<Nickname>> get watchSavedNicknames => db.watchSavedNicknames;

  Future<int> insertNewNickname(Nickname nickname) =>
      db.insertNewNickname(nickname);

  Future deleteNicknames(List<String> macAddresses) =>
      db.deleteNicknames(macAddresses);

  Stream<List<NicknamesLastSeenJoin>> watchSavedNicknamesWithLastSeen() {
    return db.watchSavedNicknamesWithLastSeen();
  }

  Future<int> insertLastSeenDevice(LastSeenDevice lastSeen) {
    return db.insertLastSeenDevice(lastSeen);
  }

  Future<void> deleteAllLastSeen() {
    return db.deleteAllLastSeen();
  }

  void close() {
    db.close();
  }
}
