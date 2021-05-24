import 'package:moor/moor.dart';

class ViveBaseStationIds extends Table {
  TextColumn get deviceId => text().withLength(min: 17, max: 37)();

  IntColumn get baseStationId => integer()();

  @override
  Set<Column> get primaryKey => {deviceId};
}
