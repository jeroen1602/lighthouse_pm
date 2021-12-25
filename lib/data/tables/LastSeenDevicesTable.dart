import 'package:drift/drift.dart';

class LastSeenDevices extends Table {
  TextColumn get deviceId => text().withLength(min: 17, max: 37)();

  DateTimeColumn get lastSeen =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {deviceId};
}
