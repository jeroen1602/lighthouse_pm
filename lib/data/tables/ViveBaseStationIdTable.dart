import 'package:moor/moor.dart';

class ViveBaseStationIds extends Table {
  IntColumn get id => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
