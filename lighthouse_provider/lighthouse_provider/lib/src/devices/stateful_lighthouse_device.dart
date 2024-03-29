part of '../../lighthouse_provider.dart';

mixin StatefulLighthouseDevice on LighthouseDevice {
  ///
  /// Disconnect from the device and clean up the connection.
  ///
  @override
  Future disconnect() async {
    await _powerStateSubscription?.cancel();
    // ignore: unnecessary_null_comparison
    if (_powerState != null && !_powerState.isClosed) {
      _powerState.close();
    }
    return super.disconnect();
  }

  ///
  /// The update interval for this device.
  ///
  @protected
  @nonVirtual
  Duration updateInterval = const Duration(milliseconds: 1000);

  ///
  /// Convert a device specific state byte to a global `LighthousePowerState`.
  ///
  LighthousePowerState powerStateFromByte(final int byte);

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
        lighthouseLogger.config("Overwritten min update interval, "
            "stuttering devices may be in your future");
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
  /// Set the preferred update interval for this device.
  /// The update interval may be higher than the preferred value because of the
  /// value returned by [getMinUpdateInterval].
  ///
  @nonVirtual
  void setUpdateInterval(final Duration interval) {
    updateInterval = interval;
  }

  ///
  /// Get the current power state as a device specific byte.
  ///
  @protected
  Future<int?> getCurrentState();

  /// Get the power state of the device as a device specific int.
  Stream<int> get powerState {
    _startPowerStateStream();
    return _powerState.stream;
  }

  ///Get the power state of the device as a [LighthousePowerState] "enum".
  Stream<LighthousePowerState> get powerStateEnum => powerState.map((final e) {
        return powerStateFromByte(e);
      });

  // ignore: close_sinks
  final BehaviorSubject<int> _powerState = BehaviorSubject.seeded(0xFF);
  StreamSubscription? _powerStateSubscription;

  /// Start the power state stream.
  ///
  /// If this method is called while there is already an active stream then it
  /// will do nothing.
  void _startPowerStateStream() {
    final stack = StackTrace.current;
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
            .listen((final _) async {
      if (hasOpenConnection) {
        if (!transactionMutex.isLocked) {
          retryCount = 0;
          try {
            await transactionMutex.acquire(stack);
            final data = await getCurrentState().timeout(Duration(seconds: 5));
            if (_powerState.isClosed) {
              await disconnect();
              return;
            }
            if (data != null) {
              _powerState.add(data);
            }
          } catch (e, s) {
            lighthouseLogger.severe(
                "Could not get state from $name, maybe the device is already disconnected",
                e,
                s);
            await disconnect();
            return;
          } finally {
            transactionMutex.release();
          }
        } else {
          if (retryCount++ > 5) {
            lighthouseLogger
                .shout("Unable to get power state from $name because the "
                    "mutex has been locked for a while ($retryCount)."
                    "\nLocked by: ${transactionMutex.lockTrace?.toString()}");
          }
        }
      } else {
        lighthouseLogger.info("Cleaning-up old subscription! For $name");
        disconnect();
      }
    });
    powerStateSubscription.onDone(() {
      lighthouseLogger.info("Cleaning-up power state subscription! For $name");
      _powerStateSubscription = null;
    });
    _powerStateSubscription = powerStateSubscription;
  }
}
