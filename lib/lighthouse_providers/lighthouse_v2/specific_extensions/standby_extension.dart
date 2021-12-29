part of lighthouse_v2_device_provider;

///
/// An extension to allow a device to go into standby mode
///
class StandbyExtension extends StateExtension {
  StandbyExtension(
      {required ChangeStateFunction changeState,
      required Stream<LighthousePowerState> powerStateStream})
      : super(
            toolTip: "Standby",
            icon:
                Icon(Icons.power_settings_new, size: 24, color: Colors.orange),
            changeState: changeState,
            powerStateStream: powerStateStream,
            toState: LighthousePowerState.standby);
}

extension StandbyExtensionExtensions on LighthouseDevice {
  bool get hasStandbyExtension {
    if (this is! DeviceWithExtensions) {
      return false;
    }
    final device = this as DeviceWithExtensions;
    return device.deviceExtensions.cast<DeviceExtension?>().firstWhere(
            (element) => element is StandbyExtension,
            orElse: () => null) !=
        null;
  }
}
