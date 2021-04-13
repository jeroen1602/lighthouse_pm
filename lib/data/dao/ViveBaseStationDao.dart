import 'package:flutter/foundation.dart';
import 'package:moor/moor.dart';

import '../Database.dart';
import '../tables/ViveBaseStationIdTable.dart';

part 'ViveBaseStationDao.g.dart';

@UseDao(tables: [ViveBaseStationIds])
class ViveBaseStationDao extends DatabaseAccessor<LighthouseDatabase>
    with _$ViveBaseStationDaoMixin {
  ViveBaseStationDao(LighthouseDatabase attachedDatabase)
      : super(attachedDatabase);

  Future<int?> getIdOnSubset(int subset) {
    assert((subset & 0xFFFF) == subset,
        'Subset should only be the lower 2 bytes. Subset was: 0x${subset.toRadixString(16)}');
    return select(viveBaseStationIds).get().then((baseStationIds) {
      for (final baseStationId in baseStationIds) {
        if ((baseStationId.id & 0xFFFF) == subset) {
          return baseStationId.id;
        }
      }
      return null;
    });
  }

  Stream<List<int>> getIdsAsStream() {
    return select(viveBaseStationIds).watch().map((event) {
      if (event.isEmpty) {
        return [];
      }
      final out = List<int>.filled(event.length, 0);
      for (int i = 0; i < event.length; i++) {
        out[i] = event[i].id;
      }
      return out;
    });
  }

  Future<void> insertId(int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16)}');

    return into(viveBaseStationIds)
        .insert(ViveBaseStationId(id: id), mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteId(int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16)}');

    return (delete(viveBaseStationIds)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> deleteIds() {
    return delete(viveBaseStationIds).go();
  }

  Stream<List<ViveBaseStationId>> get watchViveBaseStationIds {
    debugPrint(
        'WARNING using watchSimpleSettings, this should not happen in release mode!');
    return select(viveBaseStationIds).watch();
  }

  Future<void> insertIdNoValidate(int id) {
    debugPrint(
        'WARNING using insertIdNoValidate, this should not happen in release mode!');
    return into(viveBaseStationIds)
        .insert(ViveBaseStationId(id: id), mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteIdNoValidate(int id) {
    debugPrint(
        'WARNING using deleteIdNoValidate, this should not happen in release mode!');
    return (delete(viveBaseStationIds)..where((tbl) => tbl.id.equals(id))).go();
  }
}
