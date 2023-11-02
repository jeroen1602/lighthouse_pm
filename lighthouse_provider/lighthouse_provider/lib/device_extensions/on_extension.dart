part of 'device_extension.dart';

///
/// An extension to allow a device to turn on
///
class OnExtension extends StateExtension {
  OnExtension({required super.changeState, required super.powerStateStream})
      : super(toolTip: "On", toState: LighthousePowerState.on);
}
