import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lighthouse_pm/lighthouseProvider/ble/DeviceIdentifier.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import 'LighthousePowerState.dart';

abstract class LighthouseDevice {
  ///
  /// Get the device's name.
  ///
  String get name;

  ///
  /// Get the identifier for the device.
  ///
  LHDeviceIdentifier get deviceIdentifier;

  ///
  /// Disconnect from the device and clean up the connection.
  ///
  Future disconnect() async {
    if (_powerStateSubscription != null) {
      await _powerStateSubscription.cancel();
    }
    await this._powerState.close();
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
  /// Get the update interval that this device supports.
  ///
  @protected
  Duration getUpdateInterval() {
    return const Duration(milliseconds: 1000);
  }

  ///
  /// Get the current power state as a device specific byte.
  ///
  @protected
  Future<int /*?*/ > getCurrentState();

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
    this._startPowerStateStream();
    return this._powerState.stream;
  }

  ///Get the power state of the device as a [LighthousePowerState] "enum".
  Stream<LighthousePowerState> get powerStateEnum => this.powerState.map((e) {
        return powerStateFromByte(e);
      });

  BehaviorSubject<int> _powerState = BehaviorSubject.seeded(0xFF);
  StreamSubscription /* ? */ _powerStateSubscription;
  final Mutex _transaction = Mutex();

  ///Change the state of the device.
  ///
  /// The only valid options are:
  ///  - [LighthousePowerState.ON]
  ///  - [LighthousePowerState.STANDBY]
  ///
  /// When an invalid [newState] is given then this will only be logged in the
  /// console and `return` immediately.
  /// If for what ever reason the [isValid] function didn't complete correctly
  /// and then this method is called, then it will also just `return`.
  Future changeState(LighthousePowerState newState) async {
    if (newState == LighthousePowerState.UNKNOWN) {
      debugPrint('Cannot set powerstate to unknown');
      return;
    }
    if (newState == LighthousePowerState.BOOTING) {
      debugPrint('Cannot change powerstate to booting');
      return;
    }
    try {
      await _transaction.acquire();
      await internalChangeState(newState);
    } finally {
      _transaction.release();
    }
  }

  /// Start the power state stream.
  ///
  /// If this method is called while there is already an active stream then it
  /// will do nothing.
  void _startPowerStateStream() {
    if (this._powerStateSubscription != null) {
      if (this._powerStateSubscription.isPaused) {
        this._powerStateSubscription.resume();
        return;
      }
      return;
    }
    _powerStateSubscription =
        Stream.periodic(getUpdateInterval()).listen((_) async {
      if (hasOpenConnection) {
        if (!_transaction.isLocked) {
          try {
            await _transaction.acquire();
            final data = await getCurrentState();
            if (this._powerState.isClosed) {
              await this.disconnect();
              return;
            }
            if (data != null) {
              this._powerState.add(data);
            }
          } catch (e, s) {
            debugPrint('$e');
            debugPrint('$s');
          } finally {
            _transaction.release();
          }
        }
      } else {
        debugPrint('Cleaning-up old subscription!');
        final subscription = this._powerStateSubscription;
        if (subscription != null) {
          subscription.cancel();
        }
      }
    });
    _powerStateSubscription.onDone(() {
      debugPrint('Cleaning-up power state subscription!');
      _powerStateSubscription = null;
    });
  }
}
