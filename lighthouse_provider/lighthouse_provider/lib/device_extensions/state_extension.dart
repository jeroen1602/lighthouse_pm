part of device_extension;

typedef ChangeStateFunction = Future<void> Function(
    LighthousePowerState newState);

typedef GetPowerStateStream = Stream<LighthousePowerState> Function();

///
/// An extension for some extra states a device might have.
///
abstract class StateExtension extends DeviceExtension {
  StateExtension(
      {required final String toolTip,
      required final ChangeStateFunction changeState,
      required this.powerStateStream,
      required this.toState})
      : super(toolTip: toolTip, onTap: () => changeState(toState)) {
    super.streamEnabledFunction = _enabledStream;
    assert(
        toState != LighthousePowerState.unknown &&
            toState != LighthousePowerState.booting,
        'Cannot have a StateExtension that sets the power state to ${toState.text.toUpperCase()}');
  }

  final GetPowerStateStream powerStateStream;
  final LighthousePowerState toState;

  Stream<bool> _enabledStream() {
    return powerStateStream().map((final state) {
      return state != LighthousePowerState.booting && state != toState;
    });
  }
}
