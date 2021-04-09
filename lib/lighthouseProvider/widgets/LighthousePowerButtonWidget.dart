import 'package:flutter/material.dart';

import '../LighthousePowerState.dart';

/// A toggle button for the power state of a [LighthouseDevice].
class LighthousePowerButtonWidget extends StatelessWidget {
  LighthousePowerButtonWidget({
    Key? key,
    required this.powerState,
    required this.onPress,
    this.onLongPress,
  }) : super(key: key);
  final LighthousePowerState powerState;
  final VoidCallback onPress;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    var color = Colors.grey;
    switch (powerState) {
      case LighthousePowerState.ON:
        color = Colors.green;
        break;
      case LighthousePowerState.SLEEP:
        color = Colors.blue;
        break;
      case LighthousePowerState.STANDBY:
        color = Colors.orange;
        break;
      case LighthousePowerState.BOOTING:
        color = Colors.yellow;
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: RawMaterialButton(
          onPressed: onPress,
          onLongPress: onLongPress,
          elevation: 2.0,
          fillColor: Theme.of(context).buttonColor,
          padding: const EdgeInsets.all(2.0),
          shape: CircleBorder(),
          child: Icon(
            Icons.power_settings_new,
            color: color,
            size: 24.0,
          )),
    );
  }
}
