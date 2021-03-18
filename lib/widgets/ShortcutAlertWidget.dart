import 'package:flutter/material.dart';

/// Show a warning to the user about support still being in beta.
class ShortcutBetaAlertWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Shortcuts are still in beta'),
      content:
          Text('The support for shortcuts is still in beta and a bit buggy. '
              'It does currently happen sometimes for the shortcut handler to '
              'make a lighthouse hang, after this you will need to manually '
              'restart your lighthouse.\n'
              'Are you sure you want to enable this?'),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShortcutBetaAlertWidget();
        }).then((value) {
      if (value == null) {
        return false;
      }
      return value;
    });
  }
}

///
/// A dialog for explaining why shortcuts aren't supported on this Android
/// device.
///
class ShortcutNotSupportedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Shortcuts are not supported on your device'),
      content: Text('The Android version on your device is too old to support '
          'shortcuts. You need Android 8.0 or higher.\n'
          'Sorry.'),
      actions: <Widget>[
        SimpleDialogOption(
          child: Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  static Future<void> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShortcutNotSupportedWidget();
        });
  }
}
