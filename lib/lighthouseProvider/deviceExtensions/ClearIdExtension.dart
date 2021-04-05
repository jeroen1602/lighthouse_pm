import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';

import 'DeviceExtension.dart';

class ClearIdExtension extends DeviceExtension {
  ClearIdExtension(
      {required ViveBaseStationDao viveDao,
      required int deviceIdEnd,
      required VoidCallback clearId})
      : super(
            toolTip: 'Clear id',
            icon: Text('ID'),
            updateListAfter: true,
            onTap: () async {
              final id = await viveDao.getIdOnSubset(deviceIdEnd);
              if (id != null) {
                await viveDao.deleteId(id);
              }
              clearId();
            }) {
    assert(
        deviceIdEnd & 0xFFFF == deviceIdEnd, 'Device id end should be 2 bytes');
    streamEnabledFunction = () {
      return viveDao.getIdsAsStream().map((events) {
        for (final event in events) {
          if (event & 0xFFFF == deviceIdEnd) {
            return true;
          }
        }
        return false;
      });
    };
  }
}
