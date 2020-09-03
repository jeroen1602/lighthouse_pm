
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';

///
/// An abstract super class of what all device provider should be able to do.
///
abstract class DeviceProvider<D> {

  ///
  /// A simple check to see if the name matches with what the device provider
  /// expects. If the name doesn't matter for the device provider just always
  /// return true.
  bool nameCheck(String name);

  ///
  /// Connect to a device and return a super class of [LighthouseDevice].
  ///
  /// [device] the specific device to connect to and test.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  Future<LighthouseDevice/*?*/> getDevice(D device);

  ///
  /// Close any open connections that may have been made for discovering devices.
  /// If no open connection have been made this can just return.
  ///
  Future disconnectRunningDiscoveries();

}
