import 'package:moor/moor.dart';

class LastSeenDevices extends Table {
  TextColumn get macAddress => text().withLength(min: 17, max: 17)();

  DateTimeColumn get lastSeen =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {macAddress};
}
