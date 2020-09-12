import 'package:lighthouse_pm/data/Database.dart';

class LighthousePMBloc {
  final LighthouseDatabase db;

  LighthousePMBloc() : db = LighthouseDatabase();

  Stream<List<Nickname>> get watchSavedNicknames => db.watchSavedNicknames;

  Future<int> insertNewNickname(Nickname nickname) =>
      db.insertNewNickname(nickname);

  void close() {
    db.close();
  }
}
