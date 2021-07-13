import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor/moor.dart';

class Nicknames extends Table {
  TextColumn get deviceId => text().withLength(min: 17, max: 37)();

  TextColumn get nickname => text()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class NicknamesHelper {
  final String deviceId;
  final String? nickname;

  NicknamesHelper({required this.deviceId, this.nickname});

  Nickname? toNickname() {
    final nickname = this.nickname;
    if (nickname == null) {
      return null;
    }
    return Nickname(deviceId: this.deviceId, nickname: nickname);
  }
}

class NicknamesLastSeenJoin {
  NicknamesLastSeenJoin(this.deviceId, this.nickname, this.lastSeen);

  final String deviceId;
  final String nickname;
  final DateTime? lastSeen;
}
