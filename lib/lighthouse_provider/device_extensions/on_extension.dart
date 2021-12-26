import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouse_provider/lighthouse_provider.dart';

import 'state_extension.dart';

///
/// An extension to allow a device to turn on
///
class OnExtension extends StateExtension {
  OnExtension(
      {required ChangeStateFunction changeState,
      required Stream<LighthousePowerState> powerStateStream})
      : super(
            toolTip: "On",
            icon: Icon(Icons.power_settings_new, size: 24, color: Colors.green),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.on);
}
