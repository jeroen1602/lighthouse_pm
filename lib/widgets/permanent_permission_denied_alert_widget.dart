import 'package:device_info/device_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

class PermanentPermissionDeniedAlertWidget extends StatelessWidget {
  PermanentPermissionDeniedAlertWidget(this.sdkInt, {Key? key})
      : super(key: key);

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
      return "Bluetooth permission is required on Android to use "
          "Bluetooth Low Energy.\nOpen settings and go to permissions "
          "to enable Nearby devices.";
    } else {
      return "Location permissions are required on Android to use "
          "Bluetooth Low Energy.\nOpen settings and go to permissions "
          "to enable location permissions (while app is in use).";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
        title: Text(_getTitle()),
        content: RichText(
            text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
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
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          SimpleDialogOption(
            child: Text("Open settings"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ]);
  }

  static Future<bool> showCustomDialog(BuildContext context) {
    return DeviceInfoPlugin().androidInfo.then((deviceInto) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return PermanentPermissionDeniedAlertWidget(
                deviceInto.version.sdkInt);
          }).then((value) {
        if (value is bool) {
          return value;
        }
        return false;
      });
    });
  }
}
