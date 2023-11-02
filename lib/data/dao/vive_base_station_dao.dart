import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database.dart';
import '../tables/vive_base_station_id_table.dart';

part 'vive_base_station_dao.g.dart';

@DriftAccessor(tables: [ViveBaseStationIds])
class ViveBaseStationDao extends DatabaseAccessor<LighthouseDatabase>
    with _$ViveBaseStationDaoMixin {
  ViveBaseStationDao(super.attachedDatabase);

  Future<int?> getId(final String deviceId) {
    return (select(viveBaseStationIds)
          ..where((final tbl) => tbl.deviceId.equals(deviceId)))
        .getSingleOrNull()
        .then((final value) => value?.baseStationId);
  }

  Stream<List<ViveBaseStationId>> getViveBaseStationIdsAsStream() {
    return select(viveBaseStationIds).watch();
  }

  Future<void> insertId(final String deviceId, final int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16).padLeft(8, '0').toUpperCase()}');

    return into(viveBaseStationIds).insert(
        ViveBaseStationId(deviceId: deviceId, baseStationId: id),
        mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteId(final String deviceId) {
    return (delete(viveBaseStationIds)
          ..where((final tbl) => tbl.deviceId.equals(deviceId)))
        .go();
  }

  Future<void> deleteIds() {
    return delete(viveBaseStationIds).go();
  }

  Future<void> insertIdNoValidate(final String deviceId, final int id) {
    debugPrint(
        'WARNING using insertIdNoValidate, this should not happen in release mode!');
    return into(viveBaseStationIds).insert(
        ViveBaseStationId(deviceId: deviceId, baseStationId: id),
        mode: InsertMode.insertOrReplace);
  }
}
