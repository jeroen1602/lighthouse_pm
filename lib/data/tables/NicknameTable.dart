import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor/moor.dart';

class Nicknames extends Table {
  TextColumn get macAddress => text().withLength(min: 17, max: 17)();

  TextColumn get nickname => text()();

  @override
  Set<Column> get primaryKey => {macAddress};
}

class NicknamesHelper {
  final String macAddress;
  final String? nickname;

  NicknamesHelper({required this.macAddress, this.nickname});

  Nickname? toNickname() {
    final nickname = this.nickname;
    if (nickname == null) {
      return null;
    }
    return Nickname(macAddress: this.macAddress, nickname: nickname);
  }
}
