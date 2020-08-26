import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

///
/// A simple class with helper functions to check if the device is allowed to use
/// BLE.
///
class BLEPermissionsHelper {
  ///
  /// A function to check if the app is allowed to use BLE.
  /// On Android the device is only allowed to use BLE if the location permission
  /// has been granted by the user.
  ///
  /// On iOS the app is  always allowed to use BLE.
  ///
  /// May throw [UnsupportedError] if the platform is not supported.
  static Future<PermissionStatus> hasBLEPermissions() async {
    if (Platform.isIOS) {
      return PermissionStatus.granted;
    }
    if (Platform.isAndroid) {
      return await Permission.locationWhenInUse.status;
    }
    throw new UnsupportedError("ERROR: unsupported platform! $Platform");
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
    if (Platform.isAndroid) {
      return await Permission.locationWhenInUse.request();
    }
    if (Platform.isIOS) {
      return PermissionStatus.granted;
    }
    throw new UnsupportedError("ERROR: unsupported platform! $Platform");
  }
}
