import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/pages/AboutPage.dart';
import 'package:lighthouse_pm/pages/PrivacyPage.dart';

class PermanentPermissionDeniedAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Location permissions required"),
        content: RichText(
            text: TextSpan(children: <InlineSpan>[
          TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1,
              text:
                  "Location permissions are required on Android to use Bluetooth Low Energy.\nOpen settings and go to permissions to enable location permissions (while app is in use).\n"),
          TextSpan(
            text: "More info.",
            style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(
                color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutPage()));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PrivacyPage()));
              },
          )
        ])),
        actions: <Widget>[
          FlatButton(
            child: Text("Open settings"),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, false);
            },
          )
        ]);
  }

  static Future<bool> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PermanentPermissionDeniedAlertWidget();
        });
  }
}
