import 'package:flutter/material.dart';

/// A warning dialog for when the user wants to add 2 different device types
/// to the same group.
class DifferentGroupItemTypesAlertWidget extends StatefulWidget {
  const DifferentGroupItemTypesAlertWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DifferentGroupItemTypesAlertWidgetContent();
  }

  /// Show the dialog.
  ///
  /// Returns a [bool] that will be `true` if the user really wants to continue.
  /// Will be `false` if the user cancels the dialog.
  static Future<bool> showCustomDialog(final BuildContext context) {
    return showDialog(
      context: context,
      builder: (final BuildContext context) {
        return const DifferentGroupItemTypesAlertWidget();
      },
    ).then((final value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}

class _DifferentGroupItemTypesAlertWidgetContent
    extends State<DifferentGroupItemTypesAlertWidget> {
  @override
  Widget build(final BuildContext context) {
    return AlertDialog(
      title: const Text('Not all devices have the same type'),
      content: const Text(
        'Not all the devices you want to add to the group'
        ' are of the same type, this could cause problems with your VR setup.'
        ' No vr headset support 2 different types of base stations.'
        '\nAre you sure you want to do this?',
      ),
      actions: [
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: const Text('I\'m sure'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
