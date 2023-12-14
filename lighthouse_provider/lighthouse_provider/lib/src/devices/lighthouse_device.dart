part of '../../lighthouse_provider.dart';

abstract class LighthouseDevice {
  ///
  /// Get the device's name.
  ///
  String get name;

  ///
  /// The type of the device.
  ///
  String get deviceType;

  ///
  /// The nickname of the device. This should be updated anytime the user
  /// changes it.
  ///
  @protected
  @visibleForTesting
  String? nicknameInternal;

  ///
  /// Set the nickname of the device.
  ///
  set nickname(final String? nickname) {
    nicknameInternal = nickname;
  }

  ///
  /// Get the firmware version of the device.
  ///
  String get firmwareVersion;

  ///
  /// Other reported info.
  ///
  Map<String, String?> get otherMetadata;

  ///
  /// Get the identifier for the device.
  ///
  LHDeviceIdentifier get deviceIdentifier;

  ///
  /// Disconnect from the device and clean up the connection.
  ///
  Future disconnect() async {
    await internalDisconnect();
  }

  ///
  /// Disconnecting for the devices up in the chain.
  ///
  @protected
  Future internalDisconnect();

  ///
  /// Change the actual state of the device.
  /// For implementing you don't have to check the [newState] to see if it's legal
  /// since the parent [changeState] function already did this.
  @protected
  Future internalChangeState(final LighthousePowerState newState);

  ///
  /// If the device has an open connection.
  ///
  bool get hasOpenConnection;

  ///
  /// This is the mutex used for transactions.
  /// It should only be used fox extra calls, [DeviceExtensions] may add the
  /// need to add extra transaction calls to the device.
  ///
  /// [internalChangeState], and [getCurrentState] are already protected by this
  /// mutex and thus there is no need to add it extra. The app will deadlock
  /// itself if you do try to obtain the mutex in these functions.
  ///
  ///
  @visibleForTesting
  @protected
  final MutexWithStack transactionMutex = MutexWithStack();

  ///Change the state of the device.
  ///
  /// The only valid options are:
  ///  - [LighthousePowerState.on]
  ///  - [LighthousePowerState.sleep]
  ///
  /// When an invalid [newState] is given then this will only be logged in the
  /// console and `return` immediately.
  /// If for what ever reason the [isValid] function didn't complete correctly
  /// and then this method is called, then it will also just `return`.
  ///
  /// [context] is some context that is needed for the specific device to
  /// request extra data from the user. For example a build context from Flutter,
  /// or a database instance. Devices that need it will have a method on their
  /// specific [DeviceProvider] class. Make sure to set the handler function or
  /// else you may run into errors.
  ///
  Future<void> changeState<C>(final LighthousePowerState newState,
      [final C? context]) async {
    if (newState == LighthousePowerState.unknown) {
      lighthouseLogger.warning("Cannot set power state to unknown");
      return;
    }
    if (newState == LighthousePowerState.booting) {
      lighthouseLogger.warning("Cannot set power state to booting");
      return;
    }
    final request = await requestExtraInfo(context);
    if (request) {
      final stack = StackTrace.current;
      await transactionMutex.protect(
          () => internalChangeState(newState), stack);
    } else {
      lighthouseLogger.warning("Could not change state because the needed "
          "extra info hasn't been provided");
    }
  }

  ///
  /// This is an abstract method, with this method the specific device may
  /// request extra information it needs from the user, or some database. The
  /// actual implementation depends on the devices and its [DeviceProvider].
  ///
  /// So make sure to read their documentation if they need specific information.
  ///
  /// [context] is some object of choice send along with the request to the
  /// device. You may need to supply the device's [DeviceProvider] with a
  /// method to handle the actual acquisition of the data.
  ///
  /// Returns a [Future] with a [bool] if the device is now able to change
  /// state. If it is `false`, then that means that the device is not ready to
  /// change state and thus unable to do so.
  ///
  Future<bool> requestExtraInfo<C>([final C? context]) async {
    return true;
  }
}
