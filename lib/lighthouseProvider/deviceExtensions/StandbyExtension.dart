import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'DeviceWithExtensions.dart';

import '../LighthouseDevice.dart';
import '../LighthousePowerState.dart';
import 'StateExtension.dart';

///
/// An extension to allow a device to go into standby mode
///
class StandbyExtension extends StateExtension {
  StandbyExtension(
      {@required ChangeStateFunction changeState,
      @required Stream<LighthousePowerState> powerStateStream})
      : super(
            toolTip: "Standby",
            icon:
                Icon(Icons.power_settings_new, size: 24, color: Colors.orange),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.STANDBY);
}

extension StandbyExtensionExtensions on LighthouseDevice {
  bool get hasStandbyExtension {
    if (!(this is DeviceWithExtensions)) {
      return false;
    }
    final device = this as DeviceWithExtensions;
    for (final extension in device.deviceExtensions) {
      if (extension is StandbyExtension) {
        return true;
      }
    }
    return false;
  }
}
