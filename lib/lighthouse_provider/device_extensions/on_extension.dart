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
            icon: Icon(Icons.power_settings_new, size: 24, color: Colors.green),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.on);
}
