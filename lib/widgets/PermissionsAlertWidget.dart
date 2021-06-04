import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_pm/Theming.dart';

class PermissionsAlertWidget extends StatelessWidget {

  const PermissionsAlertWidget({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
        title: const Text("Location permissions required"),
        content: RichText(
            text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
          const TextSpan(
              text:
                  "Location permissions are required on Android to use Bluetooth Low Energy.\n"),
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

  static Future<bool?> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PermissionsAlertWidget();
        });
  }
}
