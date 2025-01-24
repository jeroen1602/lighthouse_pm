import 'package:flutter/material.dart';
import 'package:lighthouse_pm/lighthouse_provider/widgets/widget_for_extension.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_pm/theming.dart';

/// A toggle button for the power state of a [LighthouseDevice].
class LighthousePowerButtonWidget extends StatelessWidget {
  const LighthousePowerButtonWidget({
    super.key,
    required this.powerState,
    required this.onPress,
    this.onLongPress,
    this.disabled = false,
  });
  final LighthousePowerState powerState;
  final VoidCallback onPress;
  final VoidCallback? onLongPress;
  final bool disabled;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    final style = getButtonStyleFromState(theming, powerState);
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: disabled ? null : onPress,
        onLongPress: onLongPress,
        style: style,
        child: const Icon(
          Icons.power_settings_new,
          color: Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    );
  }
}
