import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lighthouse_provider/lighthouse_provider.dart';
import 'package:lighthouse_providers/lighthouse_v2_device_provider.dart';
import 'package:lighthouse_pm/links.dart';
import 'package:lighthouse_pm/theming.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../helpers/custom_long_press_gesture_recognizer.dart';

/// An alert dialog to ask the user what to do since the state is unknown.
class UnknownStateAlertWidget extends StatelessWidget {
  const UnknownStateAlertWidget(this.device, this.currentState,
      {final Key? key})
      : super(key: key);

  final LighthouseDevice device;
  final int currentState;

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    final actions = <Widget>[
      SimpleDialogOption(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.pop(context, null);
        },
      ),
      // Add standby, but only if it's supported
      if (device.hasStandbyExtension)
        SimpleDialogOption(
          child: const Text("Standby"),
          onPressed: () {
            Navigator.pop(context, LighthousePowerState.standby);
          },
        ),
      SimpleDialogOption(
        child: const Text("Sleep"),
        onPressed: () {
          Navigator.pop(context, LighthousePowerState.sleep);
        },
      ),
      SimpleDialogOption(
        child: const Text("On"),
        onPressed: () {
          Navigator.pop(context, LighthousePowerState.on);
        },
      ),
    ];

    return AlertDialog(
        title: const Text('Unknown state'),
        content: RichText(
          text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
            const TextSpan(
              text: 'The state of this device is unknown. What do you want '
                  'to do?\n',
            ),
            TextSpan(
              text: "Help out.",
              style: theming.linkTheme,
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await UnknownStateHelpOutAlertWidget.showCustomDialog(
                      context, device, currentState);
                },
            )
          ]),
        ),
        actions: actions);
  }

  static Future<LighthousePowerState?> showCustomDialog(
      final BuildContext context,
      final LighthouseDevice device,
      final int currentState) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return UnknownStateAlertWidget(device, currentState);
        });
  }
}

/// A dialog to ask the user to help out with unknown states
class UnknownStateHelpOutAlertWidget extends StatelessWidget {
  const UnknownStateHelpOutAlertWidget(this.device, this.currentState,
      {final Key? key})
      : super(key: key);

  final LighthouseDevice device;
  final int currentState;

  String _getClipboardString(final String version) {
    return 'App version: $version\n'
        'Device type: ${device.runtimeType}\n'
        'Firmware version: ${device.firmwareVersion}\n'
        'Current reported state: 0x${currentState.toRadixString(16).padLeft(2, '0')}\n';
  }

  GestureRecognizer createRecognizer(
      final BuildContext context, final String version) {
    return CustomLongPressGestureRecognizer()
      ..onLongPress = () async {
        Clipboard.setData(ClipboardData(text: _getClipboardString(version)));
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 200);
        }
        Toast.show('Copied to clipboard',
            duration: Toast.lengthShort, gravity: Toast.bottom);
      };
  }

  @override
  Widget build(final BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: const Text('Help out!'),
      content: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (final context, final snapshot) {
          final version = snapshot.data;
          final recognizer = version != null
              ? createRecognizer(context, version.version)
              : null;
          return RichText(
              text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
            const TextSpan(
                text: 'Help out by leaving a comment with the following '
                    'information on the github issue.\n\n'),
            TextSpan(
              text: 'App version: ',
              recognizer: recognizer,
            ),
            TextSpan(
              style: theming.bodyTextBold,
              text: '${version?.version ?? "Loading"}\n',
              recognizer: recognizer,
            ),
            TextSpan(
              text: 'Device type: ',
              recognizer: recognizer,
            ),
            TextSpan(
              style: theming.bodyTextBold,
              text: '${device.runtimeType}\n',
              recognizer: recognizer,
            ),
            TextSpan(
              text: 'Firmware version: ',
              recognizer: recognizer,
            ),
            TextSpan(
              style: theming.bodyTextBold,
              text: '${device.firmwareVersion}\n',
              recognizer: recognizer,
            ),
            TextSpan(
              text: 'Current reported state: ',
              recognizer: recognizer,
            ),
            TextSpan(
              style: theming.bodyTextBold,
              text: '0x${currentState.toRadixString(16).padLeft(2, '0')}\n',
              recognizer: recognizer,
            ),
          ]));
        },
      ),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text("Open issue"),
          onPressed: () async {
            await launchUrl(Links.stateIssueUrl,
                mode: LaunchMode.externalApplication);
          },
        ),
        SimpleDialogOption(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context, null);
          },
        )
      ],
    );
  }

  static Future<void> showCustomDialog(final BuildContext context,
      final LighthouseDevice device, final int currentState) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return UnknownStateHelpOutAlertWidget(device, currentState);
        });
  }
}
