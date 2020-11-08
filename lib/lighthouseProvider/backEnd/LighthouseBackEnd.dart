import 'dart:async';

import 'package:flutter/foundation.dart';

import '../DeviceProvider.dart';
import '../LighthouseDevice.dart';
import '../ble/DeviceIdentifier.dart';
import 'LowLevelDevice.dart';

/// A function where the parent should update the last seen and return if the device was found.
typedef UpdateLastSeen = bool Function(LHDeviceIdentifier deviceIdentifier);

/// A back end for providing a specific connection for [DeviceProvider]s.
///
/// A back end is a bridge between the native implementation and a more abstract
/// [DeviceProvider]. The back end is responsible for starting and stopping the
/// scan when called by the [LighthouseProvider]. It should also listen to the
/// incoming [Stream] of unknown devices, check if any of it's set [providers]
/// can communicate with it and return all valid device as a [lighthouseStream].
///
/// The bac end is not responsible for keeping a list of connected devices,
/// when the back end has been added to the [LighthouseProvider] it will set the
/// [updateLastSeen] function which can be used to check if the unknown device
/// is already known.
abstract class LighthouseBackEnd<T extends DeviceProvider<D>,
    D extends LowLevelDevice> {
  /// Check if a [DeviceProvider] is of a type that this [LighthouseBackEnd]
  /// supports/ uses.
  bool isMyProviderType(DeviceProvider provider) {
    return provider is T;
  }

  /// A set with all the providers for this back end.
  @protected
  Set<T> providers = Set();

  /// Add a provider for this back end.
  void addProvider(T provider) {
    providers.add(provider);
  }

  /// Remove a provider for this back end.
  void removeProvider(T provider) {
    providers.remove(provider);
  }

  /// Start scanning for devices using this back end.
  ///
  /// Will throw [StateError] if no [providers] have been set and not in release mode.
  /// In release mode it will just log to the console.
  ///
  /// Any back end that implements this method MUST await the super function first.
  @mustCallSuper
  Future<void> startScan({@required Duration timeout}) async {
    assert(updateLastSeen != null,
        'updateLastSeen should have been set by the LighthouseProvider!');
    if (providers.isEmpty) {
      if (kReleaseMode) {
        debugPrint(
            'WARNING! No device providers added for ${this.runtimeType}, no '
            'scan will be run.');
      } else {
        throw StateError('No device providers added for ${this.runtimeType}.'
            ' It\'s still in debug mode so FIX it!');
      }
    }
  }

  /// Stop scanning for devices using this back end.
  Future<void> stopScan();

  /// Cleanup the any connection artifacts.
  Future<void> cleanUp() async {}

  /// Disconnect form any open devices.
  /// If needed a subclass may override this, but be sure to call the super method!
  @mustCallSuper
  Future<void> disconnectOpenDevices() async {
    for (final bleDeviceProvider in providers) {
      await bleDeviceProvider.disconnectRunningDiscoveries();
    }
  }

  /// A stream that returns all scanned devices.
  Stream<LighthouseDevice /* ? */ > get lighthouseStream;

  /// IMPORTANT the [LighthouseProvider] should set this value when registering a back end!
  UpdateLastSeen /* ? */ updateLastSeen;

  /// Will return `null` if no device provider could validate the device.
  @protected
  Future<LighthouseDevice /* ? */ > getLighthouseDevice(D device) async {
    debugPrint('Trying to connect to device with name: ${device.name}');
    for (final provider in providers) {
      if (!provider.nameCheck(device.name)) {
        continue;
      }
      final LighthouseDevice lighthouseDevice =
          await provider.getDevice(device);
      if (lighthouseDevice != null) {
        return lighthouseDevice;
      }
    }
    return null;
  }

  /// A stream that updates if the current back end is scanning.
  /// Will return `null` if the back end doesn't support it.
  Stream<bool> /* ? */ get isScanning => null;
}
