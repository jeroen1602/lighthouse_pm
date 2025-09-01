import 'package:drift/drift.dart';

import '../database.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
}

@DataClassName('GroupEntry')
class GroupEntries extends Table {
  TextColumn get deviceId => text().withLength(min: 17, max: 37)();

  IntColumn get groupId => integer().references(
    Groups,
    #id,
    onUpdate: KeyAction.cascade,
    onDelete: KeyAction.cascade,
  )();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class GroupWithEntries {
  final Group group;
  final List<String> deviceIds;

  GroupWithEntries(this.group, this.deviceIds);
}
