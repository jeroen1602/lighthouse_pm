import 'package:flutter/material.dart';
import 'package:lighthouse_pm/Theming.dart';

import '../LighthousePowerState.dart';

/// A toggle button for the power state of a [LighthouseDevice].
class LighthousePowerButtonWidget extends StatelessWidget {
  LighthousePowerButtonWidget({
    Key? key,
    required this.powerState,
    required this.onPress,
    this.onLongPress,
    this.disabled = false,
  }) : super(key: key);
  final LighthousePowerState powerState;
  final VoidCallback onPress;
  final VoidCallback? onLongPress;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    Color color = Colors.grey;
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
          onPressed: disabled ? () {} : onPress,
          onLongPress: onLongPress,
          elevation: disabled ? 0.0 : 2.0,
          fillColor: disabled ? theming.disabledColor : theming.buttonColor,
          padding: const EdgeInsets.all(2.0),
          shape: CircleBorder(),
          child: Icon(
            Icons.power_settings_new,
            color: disabled ? Colors.grey : color,
            size: 24.0,
          )),
    );
  }
}
