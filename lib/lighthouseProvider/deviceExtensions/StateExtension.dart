import 'package:flutter/widgets.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/deviceExtensions/DeviceExtension.dart';

typedef ChangeStateFunction = Future<void> Function(
    LighthousePowerState newState);

///
/// An extension for some extra states a device might have.
///
abstract class StateExtension extends DeviceExtension {
  StateExtension(
      {required String toolTip,
      required Widget icon,
      required ChangeStateFunction changeState,
      required this.powerStateStream,
      required this.toState})
      : super(toolTip: toolTip, icon: icon, onTap: () => changeState(toState)) {
    super.streamEnabledFunction = _enabledStream;
    assert(
        toState != LighthousePowerState.UNKNOWN &&
            toState != LighthousePowerState.BOOTING,
        'Cannot have a StateExtension that sets the power state to ${toState.text.toUpperCase()}');
  }

  final Stream<LighthousePowerState> powerStateStream;
  final LighthousePowerState toState;

  Stream<bool> _enabledStream() {
    return powerStateStream.map((state) {
      return state != LighthousePowerState.BOOTING && state != toState;
    });
  }
}
