import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/dao/vive_base_station_dao.dart';

import 'device_extension.dart';

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