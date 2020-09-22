import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../LighthousePowerState.dart';
import 'StateExtension.dart';

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
