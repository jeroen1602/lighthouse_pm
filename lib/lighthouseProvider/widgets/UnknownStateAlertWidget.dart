import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthouseDevice.dart';
import 'package:lighthouse_pm/lighthouseProvider/LighthousePowerState.dart';
import 'package:lighthouse_pm/lighthouseProvider/helpers/CustomLongPressGestureRecognizer.dart';
import 'package:package_info/package_info.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

const _GITHUB_ISSUE_URL =
    "https://github.com/jeroen1602/lighthouse_pm/issues/40";

/// Am alert dialog to ask the user what to do since the state is unknown.
class UnknownStateAlertWidget extends StatelessWidget {
  UnknownStateAlertWidget(this.device, this.currentState, {Key key})
      : super(key: key);

  final LighthouseDevice device;
  final int currentState;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Unknown state'),
        content: RichText(
          text: TextSpan(children: <InlineSpan>[
            TextSpan(
              style: Theme.of(context).primaryTextTheme.bodyText1,
              text:
                  'The state of this device is unknown. What do you want to do?\n',
            ),
            TextSpan(
              text: "Help out.",
              style: Theme.of(context).primaryTextTheme.bodyText1.copyWith(
                  color: Colors.blue, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await UnknownStateHelpOutAlertWidget.showCustomDialog(
                      context, device, currentState);
                },
            )
          ]),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Start device"),
            onPressed: () {
              Navigator.pop(context, LighthousePowerState.ON);
            },
          ),
          FlatButton(
            child: Text("Shutdown device"),
            onPressed: () {
              Navigator.pop(context, LighthousePowerState.STANDBY);
            },
          ),
          FlatButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context, null);
            },
          ),
        ]);
  }

  static Future<LighthousePowerState /* ? */ > showCustomDialog(
      BuildContext context, LighthouseDevice device, int currentState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return UnknownStateAlertWidget(device, currentState);
        });
  }
}

/// A dialog to ask the user to help out with unknown states
class UnknownStateHelpOutAlertWidget extends StatelessWidget {
  UnknownStateHelpOutAlertWidget(this.device, this.currentState, {Key key})
      : super(key: key);

  final LighthouseDevice device;
  final int currentState;

  String _getClipboardString(String version) {
    return 'App version: $version\n'
        'Device type: ${device.runtimeType}\n'
        'Firmware version: ${device.firmwareVersion}\n'
        'Current reported state: 0x${currentState.toRadixString(16).padLeft(2, '0')}\n';
  }

  GestureRecognizer createRecognizer(BuildContext context, String version) {
    return CustomLongPressGestureRecognizer()
      ..onLongPress = () async {
        Clipboard.setData(ClipboardData(text: _getClipboardString(version)));
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 200);
        }
        Toast.show('Copied to clipboard', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Help out!'),
      content: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final recognizer = createRecognizer(
              context, snapshot.hasData ? snapshot.data.version : null);
          return RichText(
              text: TextSpan(children: <InlineSpan>[
            TextSpan(
                style: Theme.of(context).primaryTextTheme.bodyText1,
                text:
                    'Help out by leaving a comment with the following information on the github issue.\n\n'),
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  text: 'App version: ',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                  text:
                      '${snapshot.hasData ? snapshot.data.version : "Loading"}\n',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  text: 'Device type: ',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                  text: '${device.runtimeType}\n',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  text: 'Firmware version: ',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                  text: '${device.firmwareVersion}\n',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                  text: 'Current reported state: ',
                  recognizer: recognizer,
                ),
                TextSpan(
                  style: Theme.of(context)
                      .primaryTextTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold),
                  text: '0x${currentState.toRadixString(16).padLeft(2, '0')}\n',
                  recognizer: recognizer,
                ),
              ],
            ),
          ]));
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Open issue"),
          onPressed: () async {
            if (await canLaunch(_GITHUB_ISSUE_URL)) {
              await launch(_GITHUB_ISSUE_URL);
            }
          },
        ),
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        )
      ],
    );
  }

  static Future<Null> showCustomDialog(
      BuildContext context, LighthouseDevice device, int currentState) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return UnknownStateHelpOutAlertWidget(device, currentState);
        });
  }
}
