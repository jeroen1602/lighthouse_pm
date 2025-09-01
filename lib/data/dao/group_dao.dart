import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../database.dart';
import '../tables/group_table.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [Groups, GroupEntries])
class GroupDao extends DatabaseAccessor<LighthouseDatabase>
    with _$GroupDaoMixin {
  GroupDao(super.attachedDatabase);

  Stream<List<GroupWithEntries>> watchGroups() {
    final groupsStream = select(groups).watch();

    final groupEntriesStream = select(groupEntries).watch();

    return Rx.combineLatest2(groupsStream, groupEntriesStream, (
      final List<Group> groups,
      final List<GroupEntry> entries,
    ) {
      final combinedGroups = <GroupWithEntries>[];
      for (final group in groups) {
        final deviceIds = entries
            .where((final value) => value.groupId == group.id)
            .map((final e) => e.deviceId)
            .toList();
        combinedGroups.add(GroupWithEntries(group, deviceIds));
      }
      return combinedGroups;
    });
  }

  Stream<GroupWithEntries> watchGroup(final int groupId) {
    final groupQuery = select(groups)
      ..where((final group) => group.id.equals(groupId));

    final groupEntriesQuery = select(groupEntries).join([
      innerJoin(groups, groups.id.equalsExp(groupEntries.groupId)),
    ])..where(groupEntries.groupId.equals(groupId));

    final groupStream = groupQuery.watchSingle();

    final groupEntriesStream = groupEntriesQuery.watch().map((final rows) {
      return rows.map((final row) => row.readTable(groupEntries)).toList();
    });

    return Rx.combineLatest2(groupStream, groupEntriesStream, (
      final Group group,
      final List<GroupEntry> entries,
    ) {
      final deviceIds = entries
          .map((final entry) => entry.deviceId)
          .toList(growable: true);
      return GroupWithEntries(group, deviceIds);
    });
  }

  Future<void> insertGroup(final GroupWithEntries entry) {
    return transaction(() async {
      final group = entry.group;

      // First create the group/ update the group
      await into(groups).insert(group, mode: InsertMode.insertOrReplace);

      // Delete all known entries.
      await (delete(
        groupEntries,
      )..where((final entry) => entry.groupId.equals(group.id))).go();

      // Insert all the new entries.
      for (final deviceId in entry.deviceIds) {
        await into(groupEntries).insert(
          GroupEntry(deviceId: deviceId, groupId: group.id),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<int> insertEmptyGroup(final GroupsCompanion group) {
    return into(groups).insert(group, mode: InsertMode.insertOrReplace);
  }

  Future<int> insertJustGroup(final Group group) {
    return into(groups).insert(group, mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteGroup(final int groupId) {
    return transaction(() async {
      // Delete entries
      await (delete(
        groupEntries,
      )..where((final entry) => entry.groupId.equals(groupId))).go();

      // Delete group
      await (delete(
        groups,
      )..where((final entry) => entry.id.equals(groupId))).go();
    });
  }

  Future<void> deleteGroupEntry(final String deviceId) {
    return (delete(
      groupEntries,
    )..where((final entry) => entry.deviceId.equals(deviceId))).go();
  }

  Future<void> deleteGroupEntries(final List<String> entries) {
    return (delete(
      groupEntries,
    )..where((final tbl) => tbl.deviceId.isIn(entries))).go();
  }

  Future<void> insertGroupEntry(final GroupEntry groupEntry) {
    return into(
      groupEntries,
    ).insert(groupEntry, mode: InsertMode.insertOrReplace);
  }
}
