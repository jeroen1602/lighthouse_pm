import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';

import 'state_extension.dart';

///
/// An extension to allow a device to go into sleep mode
///
class SleepExtension extends StateExtension {
  SleepExtension(
      {required ChangeStateFunction changeState,
      required Stream<LighthousePowerState> powerStateStream})
      : super(
            toolTip: "Sleep",
            icon: Icon(Icons.power_settings_new, size: 24, color: Colors.blue),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.sleep);
}
