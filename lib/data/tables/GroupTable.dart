import 'package:moor/moor.dart';

import '../Database.dart';

class Groups extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

}

@DataClassName('GroupEntry')
class GroupEntries extends Table {
  // TextColumn get macAddress => text().withLength(min: 17, max: 17)();
  // TODO: rename to device id.
  TextColumn get macAddress => text().withLength(min: 17, max: 37)();

  IntColumn get groupId =>
      integer().customConstraint('NOT NULL REFERENCES "groups"(id) ON DELETE CASCADE ON UPDATE CASCADE')();

  @override
  Set<Column> get primaryKey => {macAddress};
}

class GroupWithEntries {
  final Group group;
  final List<String> macs;

  GroupWithEntries(this.group, this.macs);
}
