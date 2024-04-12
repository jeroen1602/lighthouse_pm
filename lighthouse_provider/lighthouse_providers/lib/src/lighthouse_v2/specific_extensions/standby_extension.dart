part of '../../../lighthouse_v2_device_provider.dart';

///
/// An extension to allow a device to go into standby mode
///
class StandbyExtension extends StateExtension {
  StandbyExtension(
      {required super.changeState, required super.powerStateStream})
      : super(toolTip: "Standby", toState: LighthousePowerState.standby);

  @override
  String get extensionName => "StandbyExtension";
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
