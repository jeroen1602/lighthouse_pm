import './LighthouseDevice.dart';
import 'backEnd/LowLevelDevice.dart';
import 'ble/Guid.dart';

///
/// An abstract super class of what all device provider should be able to do.
///
abstract class DeviceProvider<D extends LowLevelDevice> {
  ///
  /// A simple check to see if the name matches with what the device provider
  /// expects. If the name doesn't matter for the device provider just always
  /// return true.
  bool nameCheck(String name) => name.startsWith(this.namePrefix);

  ///
  /// Connect to a device and return a super class of [LighthouseDevice].
  ///
  /// [device] the specific device to connect to and test.
  /// [updateInterval] The update time for the underlying devices.
  ///
  /// Can return `null` if the device is not support by this [DeviceProvider].
  Future<LighthouseDevice?> getDevice(D device, {Duration? updateInterval});

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

  @override
  bool operator ==(Object other) {
    return this.runtimeType == other.runtimeType;
  }

  @override
  int get hashCode => super.hashCode;
}
