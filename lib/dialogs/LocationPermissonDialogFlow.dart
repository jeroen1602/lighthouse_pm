import 'package:flutter/cupertino.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseProvider.dart';
import 'package:lighthouse_pm/widgets/PermanentPermissionDeniedAlertWidget.dart';
import 'package:lighthouse_pm/widgets/PermissionsAlertWidget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../permissionsHelper/BLEPermissionsHelper.dart';

///
/// A simple class just for keeping the functions in the right place.
///
class LocationPermissionDialogFlow {
  LocationPermissionDialogFlow._();

  ///
  /// Show a dialog explaining to the user why they should enable location permissions.
  /// After the explanation the native permission dialog will show.
  /// If the native dialog is rejected forever then an extra dialog will show,
  /// explaining again why it is needed and redirecting the user to the app
  /// settings.
  ///
  /// This flow works only on Android!.
  static Future<bool> showLocationPermissionDialogFlow(BuildContext context) async {
    switch (await BLEPermissionsHelper.hasBLEPermissions()) {
      case PermissionStatus.denied:
      case PermissionStatus.undetermined:
      case PermissionStatus.restricted:
        // expression can be `null`
        if (await PermissionsAlertWidget.showCustomDialog(context) != true) {
          return false;
        }
        switch (await BLEPermissionsHelper.requestBLEPermissions()) {
          case PermissionStatus.permanentlyDenied:
            continue permanentlyDenied;
          case PermissionStatus.granted:
            continue granted;
          default:
            return false;
        }
        break;
      granted:
      case PermissionStatus.granted:
        return true;
        break;
      permanentlyDenied:
      case PermissionStatus.permanentlyDenied:
        // expression can be `null`
        if (await PermanentPermissionDeniedAlertWidget.showCustomDialog(
                context) ==
            true) {
          openAppSettings();
        }
        return false;
        break;
    }
    return true;
  }
}
