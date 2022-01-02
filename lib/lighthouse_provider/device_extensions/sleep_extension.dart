part of device_extension;

///
/// An extension to allow a device to go into sleep mode
///
class SleepExtension extends StateExtension {
  SleepExtension(
      {required ChangeStateFunction changeState,
      required GetPowerStateStream powerStateStream})
      : super(
            toolTip: "Sleep",
            icon: Icon(Icons.power_settings_new, size: 24, color: Colors.blue),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.sleep);
}
