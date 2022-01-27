part of device_extension;

///
/// An extension to allow a device to turn on
///
class OnExtension extends StateExtension {
  OnExtension(
      {required ChangeStateFunction changeState,
      required GetPowerStateStream powerStateStream})
      : super(
            toolTip: "On",
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.on);
}
