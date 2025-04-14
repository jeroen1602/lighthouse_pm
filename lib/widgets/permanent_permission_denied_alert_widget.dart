import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:shared_platform/shared_platform.dart';

class PermanentPermissionDeniedAlertWidget extends StatelessWidget {
  const PermanentPermissionDeniedAlertWidget(this.sdkInt, {super.key});

  final int sdkInt;
  String _getTitle() {
    if (SharedPlatform.isAndroid && sdkInt < 31) {
      return 'Location permissions required';
    }
    return 'Bluetooth permission required';
  }

  String _getExplanation() {
    if (SharedPlatform.isAndroid && sdkInt < 31) {
      return "Location permissions are required on Android to use "
          "Bluetooth Low Energy.\nOpen settings and go to permissions "
          "to enable location permissions (while app is in use).";
    }

    if (SharedPlatform.isIOS) {
      if (sdkInt >= 14) {
        return "To use Bluetooth Low Energy, you need to grant Bluetooth permissions. "
            "On iOS 14 and later, you might also need to enable precise location "
            "if approximate location is not sufficient.";
      }

      if (sdkInt >= 13) {
        return "To use Bluetooth Low Energy, you need to grant Bluetooth permissions. "
            "Please check your settings to ensure permissions are enabled.";
      }
    }

    return "Bluetooth permission is required to use "
        "Bluetooth Low Energy.\nOpen settings and go to permissions "
        "to enable Nearby devices.";
  }

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: Text(_getTitle()),
      content: RichText(
        text: TextSpan(
          style: theming.bodyMedium,
          children: <InlineSpan>[
            TextSpan(text: "${_getExplanation()}\n"),
            TextSpan(
              text: "More info.",
              style: theming.linkTheme,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, '/settings');
                      Navigator.pushNamed(context, '/settings/privacy');
                    },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: const Text("Open settings"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(final BuildContext context) {
    return DeviceInfoPlugin().deviceInfo.then((final deviceInfo) {
      if (!context.mounted) {
        return false;
      }
      return showDialog(
        context: context,
        builder: (final BuildContext context) {
          if (deviceInfo is AndroidDeviceInfo) {
            return PermanentPermissionDeniedAlertWidget(
              deviceInfo.version.sdkInt,
            );
          }

          if (deviceInfo is IosDeviceInfo) {
            return PermanentPermissionDeniedAlertWidget(
              int.tryParse(deviceInfo.systemVersion.split('.').first) ?? -1,
            );
          }

          return PermanentPermissionDeniedAlertWidget(-1);
        },
      ).then((final value) {
        if (value is bool) {
          return value;
        }
        return false;
      });
    });
  }
}
