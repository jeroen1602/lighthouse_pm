import 'package:moor/moor.dart';

class Nicknames extends Table {
  TextColumn get macAddress => text().withLength(min: 17, max: 17)();

  TextColumn get nickname => text().nullable()();

  @override
  Set<Column> get primaryKey => {macAddress};
}
