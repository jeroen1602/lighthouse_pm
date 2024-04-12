part of '../../lighthouse_back_end.dart';

///
/// An abstract super class of what all device provider should be able to do.
///
abstract class DeviceProvider<D extends LowLevelDevice> {
  ///
  /// A simple check to see if the name matches with what the device provider
  /// expects. If the name doesn't matter for the device provider just always
  /// return true.
  bool nameCheck(final String name) => name.startsWith(namePrefix);

  ///
  /// Connect to a device and return a super class of [LighthouseDevice].
  ///
  /// [device] the specific device to connect to and test.
  /// [updateInterval] The update time for the underlying devices.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  Future<LighthouseDevice?> getDevice(final D device,
      {final Duration? updateInterval});

  ///
  /// Close any open connections that may have been made for discovering devices.
  /// If no open connection have been made this can just return.
  ///
  Future disconnectRunningDiscoveries();

  ///
  /// A list of services that the devices this provider provides MUST have.
  ///
  List<LighthouseGuid> get requiredServices;

  ///
  /// A list of services that the devices this provider provides MAY have, the
  /// device shouldn't be rejected if these are not available.
  ///
  List<LighthouseGuid> get optionalServices;

  ///
  /// A list of all the characteristics that this provider may communicate with.
  ///
  List<LighthouseGuid> get characteristics;

  ///
  /// The name prefix that the devices must have
  ///
  String get namePrefix;

  ///
  /// The name of this device provider. This name should be unique
  ///
  String get providerName;

  @override
  bool operator ==(final Object other) {
    if (other is DeviceProvider) {
      return providerName == other.providerName;
    }
    return false;
  }

  @override
  int get hashCode => providerName.hashCode;
}
