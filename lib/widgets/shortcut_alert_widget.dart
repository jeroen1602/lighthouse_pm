import 'package:flutter/material.dart';

/// Show a warning to the user about support still being in beta.
class ShortcutBetaAlertWidget extends StatelessWidget {
  const ShortcutBetaAlertWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Shortcuts are still in beta'),
      content: const Text(
          'The support for shortcuts is still in beta and a bit buggy. '
          'It does currently happen sometimes for the shortcut handler to '
          'make a lighthouse hang, after this you will need to manually '
          'restart your lighthouse.\n'
          'Are you sure you want to enable this?'),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        SimpleDialogOption(
          child: const Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  static Future<bool> showCustomDialog(final BuildContext context) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return const ShortcutBetaAlertWidget();
        }).then((final value) {
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
  const ShortcutNotSupportedWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Shortcuts are not supported on your device'),
      content: const Text('The Android version on your device is too old to '
          'support shortcuts. You need Android 8.0 or higher.\n'
          'Sorry.'),
      actions: <Widget>[
        SimpleDialogOption(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  static Future<void> showCustomDialog(final BuildContext context) {
    return showDialog(
        context: context,
        builder: (final BuildContext context) {
          return const ShortcutNotSupportedWidget();
        });
  }
}
