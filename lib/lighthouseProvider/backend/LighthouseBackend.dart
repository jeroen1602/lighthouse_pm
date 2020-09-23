import 'dart:async';

import 'package:flutter/foundation.dart';

import '../DeviceProvider.dart';
import '../LighthouseDevice.dart';
import '../ble/DeviceIdentifier.dart';

/// A function where the parent should update the last seen and return if the device was found.
typedef UpdateLastSeen = bool Function(LHDeviceIdentifier deviceIdentifier);

/// A backend for providing a specific connection for [DeviceProvider]s.
///
/// A backend is a bridge between the native implementation and a more abstract
/// [DeviceProvider]. The backend is responsible for starting and stopping the
/// scan when called by the [LighthouseProvider]. It should also listen to the
/// incoming [Stream] of unknown devices, check if any of it's set [providers]
/// can communicate with it and return all valid device as a [lighthouseStream].
///
/// The back-end is not responsible for keeping a list of connected devices,
/// when the backend has been added to the [LighthouseProvider] it will set the
/// [updateLastSeen] function which can be used to check if the unknown device
/// is already known.
abstract class LighthouseBackend<T extends DeviceProvider> {
  /// Check if a [DeviceProvider] is of a type that this [LighthouseBackend]
  /// supports/ uses.
  bool isMyProviderType(DeviceProvider provider) {
    return provider is T;
  }

  /// A set with all the providers for this backend.
  @protected
  Set<T> providers = Set();

  /// Add a provider for this backend.
  void addProvider(T provider) {
    providers.add(provider);
  }

  /// Remove a provider for this backend.
  void removeProvider(T provider) {
    providers.remove(provider);
  }

  /// Start scanning for devices using this backend.
  ///
  /// Will throw [StateError] if no [providers] have been set and not in release mode.
  /// In release mode it will just log to the console.
  ///
  /// Any backend that implements this method MUST await the super function first.
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

  /// Stop scanning for devices using this backend.
  Future<void> stopScan();

  /// Cleanup the any connection artifacts.
  Future<void> cleanUp() async {}

  /// Disconnect form any open devices.
  /// If needed a subclass may override this, but be sure to call the super method!
  Future<void> disconnectOpenDevices() async {
    for (final bleDeviceProvider in providers) {
      await bleDeviceProvider.disconnectRunningDiscoveries();
    }
  }

  /// A stream that returns all scanned devices.
  Stream<LighthouseDevice /* ? */ > get lighthouseStream;

  /// IMPORTANT the [LighthouseProvider] should set this value when registering a backend!
  UpdateLastSeen /* ? */ updateLastSeen;
}
