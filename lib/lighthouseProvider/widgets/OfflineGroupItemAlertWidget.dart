import 'package:flutter/material.dart';

/// The returned data from the [OfflineGroupItemAlertWidget] dialog.
///
/// [dialogCanceled] will be true if the dialog is canceled,
/// [disableWarning] will be true if [dialogCanceled] is false and the user has
/// selected the don't show me this again checkbox.
///
class OfflineGroupItemAlertWidgetReturn {
  final bool dialogCanceled;
  final bool disableWarning;

  OfflineGroupItemAlertWidgetReturn._(this.dialogCanceled, this.disableWarning);
}

/// A dialog that displays a warning to the user if one of the devices in a
/// group is offline.
class OfflineGroupItemAlertWidget extends StatefulWidget {
  OfflineGroupItemAlertWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OfflineGroupItemAlertWidgetContent();
  }

  static Future<OfflineGroupItemAlertWidgetReturn> showCustomDialog(
      BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return OfflineGroupItemAlertWidget();
        }).then((value) {
      if (value is OfflineGroupItemAlertWidgetReturn) {
        return value;
      }
      return OfflineGroupItemAlertWidgetReturn._(true, false);
    });
  }
}

class _OfflineGroupItemAlertWidgetContent
    extends State<OfflineGroupItemAlertWidget> {
  bool disableWarning = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Some devices are offline'),
      content: IntrinsicHeight(
          child: Column(
        children: [
          const Text('Some devices in this group are offline, do you want to continue'
              ' and change the state of the devices that are online?'),
          CheckboxListTile(
              title: const Text("Don't show this warning again."),
              value: disableWarning,
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    disableWarning = value;
                  }
                });
              }),
        ],
      )),
      actions: [
        SimpleDialogOption(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(
                context, OfflineGroupItemAlertWidgetReturn._(true, false));
          },
        ),
        SimpleDialogOption(
          child: const Text('Continue'),
          onPressed: () {
            Navigator.pop(context,
                OfflineGroupItemAlertWidgetReturn._(false, disableWarning));
          },
        ),
      ],
    );
  }
}
