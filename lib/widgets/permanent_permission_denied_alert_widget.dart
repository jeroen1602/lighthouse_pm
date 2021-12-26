import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/theming.dart';

class PermanentPermissionDeniedAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
        title: Text("Location permissions required"),
        content: RichText(
            text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
          TextSpan(
              text: "Location permissions are required on Android to use "
                  "Bluetooth Low Energy.\nOpen settings and go to permissions "
                  "to enable location permissions (while app is in use).\n"),
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

  static Future<bool?> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PermanentPermissionDeniedAlertWidget();
        });
  }
}
