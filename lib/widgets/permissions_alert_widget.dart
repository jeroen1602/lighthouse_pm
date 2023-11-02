import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

class PermissionsAlertWidget extends StatelessWidget {
  const PermissionsAlertWidget(this.sdkInt, {super.key});

  final int sdkInt;

  String _getTitle() {
    if (sdkInt >= 31) {
      return "Bluetooth permission required";
    } else {
      return "Location permissions required";
    }
  }

  String _getExplanation() {
    if (sdkInt >= 31) {
      return "Bluetooth permission is required to communicate with the Bluetooth devices.";
    } else {
      return "Location permissions are required on Android to use Bluetooth Low Energy.";
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
        title: Text(_getTitle()),
        content: RichText(
            text: TextSpan(style: theming.bodyMedium, children: <InlineSpan>[
          TextSpan(text: "${_getExplanation()}\n"),
          TextSpan(
            text: "More info.",
            style: theming.linkTheme,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/settings');
                Navigator.pushNamed(context, '/settings/privacy');
              },
          )
        ])),
        actions: <Widget>[
          SimpleDialogOption(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          SimpleDialogOption(
            child: const Text("Allow permissions"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ]);
  }

  static Future<bool> showCustomDialog(final BuildContext context) {
    return DeviceInfoPlugin().androidInfo.then((final deviceInto) {
      return showDialog(
          context: context,
          builder: (final BuildContext context) {
            return PermissionsAlertWidget(deviceInto.version.sdkInt);
          }).then((final value) {
        if (value is bool) {
          return value;
        }
        return false;
      });
    });
  }
}
