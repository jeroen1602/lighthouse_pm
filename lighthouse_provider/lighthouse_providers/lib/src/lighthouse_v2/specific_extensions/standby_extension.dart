part of lighthouse_v2_device_provider;

///
/// An extension to allow a device to go into standby mode
///
class StandbyExtension extends StateExtension {
  StandbyExtension(
      {required final ChangeStateFunction changeState,
      required final GetPowerStateStream powerStateStream})
      : super(
            toolTip: "Standby",
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
            (final element) => element is StandbyExtension,
            orElse: () => null) !=
        null;
  }
}
