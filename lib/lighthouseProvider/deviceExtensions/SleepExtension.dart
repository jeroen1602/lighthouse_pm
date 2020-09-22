import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../LighthousePowerState.dart';
import 'StateExtension.dart';

///
/// An extension to allow a device to go into sleep mode
///
class SleepExtension extends StateExtension {
  SleepExtension(
      {@required ChangeStateFunction changeState,
      @required Stream<LighthousePowerState> powerStateStream})
      : super(
            toolTip: "Sleep",
            icon:
                Icon(Icons.power_settings_new, size: 24, color: Colors.blue),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.SLEEP);
}

