import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/data/bloc/ViveBaseStationBloc.dart';

import 'DeviceExtension.dart';

class ClearIdExtension extends DeviceExtension {
  ClearIdExtension(
      {required ViveBaseStationBloc bloc,
      required int deviceIdEnd,
      required VoidCallback clearId})
      : super(
            toolTip: 'Clear id',
            icon: Text('ID'),
            updateListAfter: true,
            onTap: () async {
              final id = await bloc.getIdOnSubset(deviceIdEnd);
              if (id != null) {
                await bloc.deleteId(id);
              }
              clearId();
            }) {
    assert(
        deviceIdEnd & 0xFFFF == deviceIdEnd, 'Device id end should be 2 bytes');
    streamEnabledFunction = () {
      return bloc.getIdsAsStream().map((events) {
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
