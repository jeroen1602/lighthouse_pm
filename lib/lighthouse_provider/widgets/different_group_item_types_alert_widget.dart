import 'package:flutter/material.dart';

/// A warning dialog for when the user wants to add 2 different device types
/// to the same group.
class DifferentGroupItemTypesAlertWidget extends StatefulWidget {
  DifferentGroupItemTypesAlertWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DifferentGroupItemTypesAlertWidgetContent();
  }

  /// Show the dialog.
  ///
  /// Returns a [bool] that will be `true` if the user really wants to continue.
  /// Will be `false` if the user cancels the dialog.
  static Future<bool> showCustomDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DifferentGroupItemTypesAlertWidget();
        }).then((value) {
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Not all devices have the same type'),
      content: Text('Not all the devices you want to add to the group'
          ' are of the same type, this could cause problems with your VR setup.'
          ' No vr headset support 2 different types of base stations.'
          '\nAre you sure you want to do this?'),
      actions: [
        SimpleDialogOption(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: Text('I\'m sure'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }
}
