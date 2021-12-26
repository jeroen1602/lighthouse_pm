import 'package:flutter/widgets.dart';

import '../lighthouse_power_state.dart';
import 'device_extension.dart';

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
        toState != LighthousePowerState.unknown &&
            toState != LighthousePowerState.booting,
        'Cannot have a StateExtension that sets the power state to ${toState.text.toUpperCase()}');
  }

  final Stream<LighthousePowerState> powerStateStream;
  final LighthousePowerState toState;

  Stream<bool> _enabledStream() {
    return powerStateStream.map((state) {
      return state != LighthousePowerState.booting && state != toState;
    });
  }
}