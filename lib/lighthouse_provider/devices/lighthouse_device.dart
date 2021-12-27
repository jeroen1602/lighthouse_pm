part of lighthouse_provider;

abstract class LighthouseDevice {
  ///
  /// Get the device's name.
  ///
  String get name;

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
  set nickname(String? nickname) {
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
  /// The update interval for this device.
  ///
  @protected
  @nonVirtual
  Duration updateInterval = const Duration(milliseconds: 1000);

  ///
  /// Disconnect from the device and clean up the connection.
  ///
  Future disconnect() async {
    await _powerStateSubscription?.cancel();
    // ignore: unnecessary_null_comparison
    if (_powerState != null && !_powerState.isClosed) {
      _powerState.close();
    }
    await internalDisconnect();
  }

  ///
  /// Disconnecting for the devices up in the chain.
  ///
  @protected
  Future internalDisconnect();

  ///
  /// Convert a device specific state byte to a global `LighthousePowerState`.
  ///
  LighthousePowerState powerStateFromByte(int byte);

  ///
  /// Get the minimum update interval that this device supports.
  ///
  @visibleForTesting
  @protected
  Duration getMinUpdateInterval() {
    return const Duration(milliseconds: 1000);
  }

  ///
  /// Overwrite the minimum update interval for testing.
  ///
  @visibleForTesting
  Duration? testingOverwriteMinUpdateInterval;

  ///
  /// Get the update interval for the device state.
  /// The update interval will never be lower than [getMinUpdateInterval] since
  /// that is the fastest interval that the device support and shouldn't be
  /// exceeded.
  ///
  @nonVirtual
  Duration getUpdateInterval() {
    var min = getMinUpdateInterval();
    assert(() {
      if (testingOverwriteMinUpdateInterval != null) {
        print("Overwritten min update interval, stuttering devices may be in your future");
        min = testingOverwriteMinUpdateInterval!;
      }
      return true;
    }());
    if (min < updateInterval) {
      return updateInterval;
    }
    return min;
  }

  ///
  /// Set the prefered update interval for this device.
  /// The update interval may be higher than the prefered value because of the
  /// value returned by [getMinUpdateInterval].
  ///
  @nonVirtual
  void setUpdateInterval(Duration interval) {
    updateInterval = interval;
  }

  ///
  /// Get the current power state as a device specific byte.
  ///
  @protected
  Future<int?> getCurrentState();

  ///
  /// Change the actual state of the device.
  /// For implementing you don't have to check the [newState] to see if it's legal
  /// since the parent [changeState] function already did this.
  @protected
  Future internalChangeState(LighthousePowerState newState);

  ///
  /// If the device has an open connection.
  ///
  bool get hasOpenConnection;

  /// Get the power state of the device as a device specific int.
  Stream<int> get powerState {
    _startPowerStateStream();
    return _powerState.stream;
  }

  ///Get the power state of the device as a [LighthousePowerState] "enum".
  Stream<LighthousePowerState> get powerStateEnum => powerState.map((e) {
        return powerStateFromByte(e);
      });

  // ignore: close_sinks
  final BehaviorSubject<int> _powerState = BehaviorSubject.seeded(0xFF);
  StreamSubscription? _powerStateSubscription;

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
  final Mutex transactionMutex = Mutex();

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
  Future changeState(LighthousePowerState newState) async {
    if (newState == LighthousePowerState.unknown) {
      print('Cannot set power state to unknown');
      return;
    }
    if (newState == LighthousePowerState.booting) {
      print('Cannot change power state to booting');
      return;
    }
    try {
      await transactionMutex.acquire();
      await internalChangeState(newState);
    } finally {
      transactionMutex.release();
    }
  }

  /// Show an extra window for the user to fill in extra info needed for the
  /// lighthouse device.
  /// Will not show a dialog if the device is already excepted.
  /// Returns a [Future] with a [bool] if the device is now able to change the
  /// state.
  Future<bool> showExtraInfoWidget(BuildContext context) async {
    return true;
  }

  /// Start the power state stream.
  ///
  /// If this method is called while there is already an active stream then it
  /// will do nothing.
  void _startPowerStateStream() {
    int retryCount = 0;
    var powerStateSubscription = _powerStateSubscription;
    if (powerStateSubscription != null) {
      if (powerStateSubscription.isPaused) {
        powerStateSubscription.resume();
        return;
      }
      return;
    }
    powerStateSubscription =
        MergeStream([Stream.value(null), Stream.periodic(getUpdateInterval())])
            .listen((_) async {
      if (hasOpenConnection) {
        if (!transactionMutex.isLocked) {
          retryCount = 0;
          try {
            await transactionMutex.acquire();
            final data = await getCurrentState();
            if (_powerState.isClosed) {
              await disconnect();
              return;
            }
            if (data != null) {
              _powerState.add(data);
            }
          } catch (e, s) {
            print("Could not get state, maybe we are disconnected");
            print('$e');
            print('$s');
            await disconnect();
            return;
          } finally {
            transactionMutex.release();
          }
        } else {
          if (retryCount++ > 5) {
            print(
                'Unable to get power state because the mutex has been locked for a while ($retryCount). $transactionMutex');
          }
        }
      } else {
        print('Cleaning-up old subscription!');
        disconnect();
      }
    });
    powerStateSubscription.onDone(() {
      print('Cleaning-up power state subscription!');
      _powerStateSubscription = null;
    });
    _powerStateSubscription = powerStateSubscription;
  }
}
