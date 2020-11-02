import 'package:moor_flutter/moor_flutter.dart';

class SimpleSettings extends Table {
  IntColumn get settingsId => integer()();
  TextColumn get data => text().nullable()();

  @override
  Set<Column> get primaryKey => {settingsId};
}
