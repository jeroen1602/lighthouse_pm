import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/dao/ViveBaseStationDao.dart';

import 'DeviceExtension.dart';

class ClearIdExtension extends DeviceExtension {
  ClearIdExtension(
      {required ViveBaseStationDao viveDao,
      required String deviceId,
      required VoidCallback clearId})
      : super(
            toolTip: 'Clear id',
            icon: Text('ID'),
            updateListAfter: true,
            onTap: () async {
              await viveDao.deleteId(deviceId);
              clearId();
            }) {
    streamEnabledFunction = () {
      return viveDao.getViveBaseStationIdsAsStream().map((events) {
        for (final event in events) {
          if (event.deviceId == deviceId) {
            return true;
          }
        }
        return false;
      });
    };
  }
}
