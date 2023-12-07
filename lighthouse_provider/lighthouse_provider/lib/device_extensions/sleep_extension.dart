part of 'device_extension.dart';

///
/// An extension to allow a device to go into sleep mode
///
class SleepExtension extends StateExtension {
  SleepExtension({required super.changeState, required super.powerStateStream})
      : super(toolTip: "Sleep", toState: LighthousePowerState.sleep);
}
