import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

import '../Database.dart';
import '../tables/GroupTable.dart';

part 'GroupDao.g.dart';

@UseDao(tables: [Groups, GroupEntries])
class GroupDao extends DatabaseAccessor<LighthouseDatabase>
    with _$GroupDaoMixin {
  GroupDao(LighthouseDatabase attachedDatabase) : super(attachedDatabase);

  Stream<List<GroupWithEntries>> watchGroups() {
    final groupsStream = select(groups).watch();

    final groupEntriesStream = select(groupEntries).watch();

    return Rx.combineLatest2(groupsStream, groupEntriesStream,
        (List<Group> groups, List<GroupEntry> entries) {
      final combinedGroups = <GroupWithEntries>[];
      for (final group in groups) {
        final deviceIds = entries
            .where((value) => value.groupId == group.id)
            .map((e) => e.deviceId)
            .toList();
        combinedGroups.add(GroupWithEntries(group, deviceIds));
      }
      return combinedGroups;
    });
  }

  Stream<GroupWithEntries> watchGroup(int groupId) {
    final groupQuery = select(groups)
      ..where((group) => group.id.equals(groupId));

    final groupEntriesQuery = select(groupEntries)
        .join([innerJoin(groups, groups.id.equalsExp(groupEntries.groupId))])
          ..where(groupEntries.groupId.equals(groupId));

    final groupStream = groupQuery.watchSingle();

    final groupEntriesStream = groupEntriesQuery.watch().map((rows) {
      return rows.map((row) => row.readTable(groupEntries)).toList();
    });

    return Rx.combineLatest2(groupStream, groupEntriesStream,
        (Group group, List<GroupEntry> entries) {
      final deviceIds =
          entries.map((entry) => entry.deviceId).toList(growable: true);
      return GroupWithEntries(group, deviceIds);
    });
  }

  Future<void> insertGroup(GroupWithEntries entry) {
    return transaction(() async {
      final group = entry.group;

      // First create the group/ update the group
      await into(groups).insert(group, mode: InsertMode.insertOrReplace);

      // Delete all known entries.
      await (delete(groupEntries)
            ..where((entry) => entry.groupId.equals(group.id)))
          .go();

      // Insert all the new entries.
      for (final deviceId in entry.deviceIds) {
        await into(groupEntries).insert(
            GroupEntry(deviceId: deviceId, groupId: group.id),
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<int> insertEmptyGroup(GroupsCompanion group) {
    return into(groups).insert(group, mode: InsertMode.insertOrReplace);
  }

  Future<int> insertJustGroup(Group group) {
      return into(groups).insert(group, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteGroup(int groupId) {
    return transaction(() async {
      // Delete entries
      await (delete(groupEntries)
            ..where((entry) => entry.groupId.equals(groupId)))
          .go();

      // Delete group
      await (delete(groups)..where((entry) => entry.id.equals(groupId))).go();
    });
  }

  Future<void> deleteGroupEntry(String deviceId) {
    return (delete(groupEntries)
          ..where((entry) => entry.deviceId.equals(deviceId)))
        .go();
  }

  Future<void> deleteGroupEntries(List<String> entries) {
    return (delete(groupEntries)..where((tbl) => tbl.deviceId.isIn(entries)))
        .go();
  }

  Future<void> insertGroupEntry(GroupEntry groupEntry) {
    return into(groupEntries)
        .insert(groupEntry, mode: InsertMode.insertOrReplace);
  }
}
