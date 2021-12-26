import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/vive_base_station_id_table.dart';

part 'vive_base_station_dao.g.dart';

@DriftAccessor(tables: [ViveBaseStationIds])
class ViveBaseStationDao extends DatabaseAccessor<LighthouseDatabase>
    with _$ViveBaseStationDaoMixin {
  ViveBaseStationDao(LighthouseDatabase attachedDatabase)
      : super(attachedDatabase);

  Future<int?> getId(String deviceId) {
    return (select(viveBaseStationIds)
          ..where((tbl) => tbl.deviceId.equals(deviceId)))
        .getSingleOrNull()
        .then((value) => value?.baseStationId);
  }

  Stream<List<ViveBaseStationId>> getViveBaseStationIdsAsStream() {
    return select(viveBaseStationIds).watch();
  }

  Future<void> insertId(String deviceId, int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16).padLeft(8, '0').toUpperCase()}');

    return into(viveBaseStationIds).insert(
        ViveBaseStationId(deviceId: deviceId, baseStationId: id),
        mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteId(String deviceId) {
    return (delete(viveBaseStationIds)
          ..where((tbl) => tbl.deviceId.equals(deviceId)))
        .go();
  }

  Future<void> deleteIds() {
    return delete(viveBaseStationIds).go();
  }

  Stream<List<ViveBaseStationId>> get watchViveBaseStationIds {
    debugPrint(
        'WARNING using watchSimpleSettings, this should not happen in release mode!');
    return select(viveBaseStationIds).watch();
  }

  Future<void> insertIdNoValidate(String deviceId, int id) {
    debugPrint(
        'WARNING using insertIdNoValidate, this should not happen in release mode!');
    return into(viveBaseStationIds).insert(
        ViveBaseStationId(deviceId: deviceId, baseStationId: id),
        mode: InsertMode.insertOrReplace);
  }
}
