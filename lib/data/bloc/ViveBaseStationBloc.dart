import 'dart:async';

import 'package:lighthouse_pm/data/Database.dart';
import 'package:moor/moor.dart';

class ViveBaseStationBloc {
  ViveBaseStationBloc(this.db);

  final LighthouseDatabase db;

  Future<int?> getIdOnSubset(int subset) {
    assert((subset & 0xFFFF) == subset,
        'Subset should only be the lower 2 bytes. Subset was: 0x${subset.toRadixString(16)}');
    return db.select(db.viveBaseStationIds).get().then((baseStationIds) {
      for (final baseStationId in baseStationIds) {
        if ((baseStationId.id & 0xFFFF) == subset) {
          return baseStationId.id;
        }
      }
      return null;
    });
  }

  Stream<List<int>> getIdsAsStream() {
    return db.select(db.viveBaseStationIds).watch().map((event) {
      if (event == null || event.isEmpty) {
        return [];
      }
      final out = List<int>.filled(event.length, 0);
      for (final item in event) {
        out.add(item.id);
      }
      return out;
    });
  }

  Future<void> insertId(int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16)}');

    return db
        .into(db.viveBaseStationIds)
        .insert(ViveBaseStationId(id: id), mode: InsertMode.insertOrReplace);
  }

  Future<void> deleteId(int id) {
    assert((id & 0xFFFFFFFF) == id,
        'Id should be at most 4 bytes, Id was: 0x${id.toRadixString(16)}');

    return (db.delete(db.viveBaseStationIds)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<void> deleteIds() {
    return db.delete(db.viveBaseStationIds).go();
  }
}
