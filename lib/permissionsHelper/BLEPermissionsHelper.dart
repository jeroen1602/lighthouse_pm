import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/platformSpecific/shared/LocalPlatform.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// A simple class with helper functions to check if the device is allowed to use
/// BLE.
///
class BLEPermissionsHelper {
  BLEPermissionsHelper._();

  static const _channel =
      const MethodChannel("com.jeroen1602.lighthouse_pm/bluetooth");

  ///
  /// A function to check if the app is allowed to use BLE.
  /// On Android the device is only allowed to use BLE if the location permission
  /// has been granted by the user.
  ///
  /// On iOS the app is  always allowed to use BLE.
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<PermissionStatus> hasBLEPermissions() async {
    if (LocalPlatform.isIOS) {
      return PermissionStatus.granted;
    }
    if (LocalPlatform.isAndroid) {
      return await Permission.locationWhenInUse.status;
    }
    throw UnsupportedError(
        "ERROR: unsupported platform! ${LocalPlatform.current}");
  }

  ///
  /// A function to request the user to allow BLE permissions.
  /// On Android the device is only allowed to use BLE if the location permission
  /// has been granted by the user.
  ///
  /// On iOS the app is always allowed to use BLE and thus this will always
  /// return [PermissionStatus.granted].
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<PermissionStatus> requestBLEPermissions() async {
    if (LocalPlatform.isAndroid) {
      return await Permission.locationWhenInUse.request();
    }
    if (LocalPlatform.isIOS) {
      return PermissionStatus.granted;
    }
    throw UnsupportedError(
        "ERROR: unsupported platform! ${LocalPlatform.current}");
  }

  ///
  /// Open the bluetooth settings on the device.
  /// On Android this is possible.
  /// On iOS this function is not possible and will always return [false].
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<bool> openBLESettings() async {
    if (LocalPlatform.isAndroid) {
      return _channel.invokeMethod("openBLESettings").then((value) {
        if (value is bool) {
          return value;
        } else {
          throw TypeError();
        }
      });
    }
    if (LocalPlatform.isIOS) {
      // According to [this](https://stackoverflow.com/a/43754366/13324337) you
      // aren't allowed to open settings on ios.
      debugPrint("Can't open settings because iOS doesn't support it.");
      return false;
    }
    throw UnsupportedError(
        "ERROR: unsupported platform! ${LocalPlatform.current}");
  }

  ///
  /// Enable the bluetooth adapter on a device.
  /// On Android this is possible.
  /// On iOS this function is not possible and will always return [false].
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<bool> enableBLE() async {
    if (LocalPlatform.isAndroid) {
      return _channel.invokeMethod("enableBluetooth").then((value) {
        if (value is bool) {
          return value;
        } else {
          throw TypeError();
        }
      });
    }
    if (LocalPlatform.isIOS) {
      // iOS doesn't have an API that can handle enable bluetooth for us.
      debugPrint("Can't enable BLE on iOS since there is no api.");
      return false;
    }
    throw UnsupportedError(
        "ERROR: unsupported platform! ${LocalPlatform.current}");
  }

  ///
  /// Open location settings for a specific platform.
  /// On Android this is possible.
  /// On iOS this function nis not possible and will always return [false].
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<bool> openLocationSettings() async {
    if (LocalPlatform.isAndroid) {
      return _channel.invokeMethod("openLocationSettings").then((value) {
        if (value is bool) {
          return value;
        } else {
          throw TypeError();
        }
      });
    }
    if (LocalPlatform.isIOS) {
      // iOS doesn't have an API that can open location settings
      debugPrint("Can't open location settings on iOS since there is no api.");
      return false;
    }
    throw UnsupportedError(
        "ERROR: unsupported platform! ${LocalPlatform.current}");
  }
}
