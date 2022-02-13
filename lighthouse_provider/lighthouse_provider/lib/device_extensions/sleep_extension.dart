part of device_extension;

///
/// An extension to allow a device to go into sleep mode
///
class SleepExtension extends StateExtension {
  SleepExtension(
      {required final ChangeStateFunction changeState,
      required final GetPowerStateStream powerStateStream})
      : super(
            toolTip: "Sleep",
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.sleep);
}
