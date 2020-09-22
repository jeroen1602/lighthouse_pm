import 'package:moor_flutter/moor_flutter.dart';

class SimpleSettings extends Table {
  IntColumn get id => integer()();
  TextColumn get data => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
