import 'package:flutter/material.dart';
import 'package:lighthouse_pm/Theming.dart';
import 'package:lighthouse_pm/data/Database.dart';

class DeleteGroupAlertWidget extends StatelessWidget {
  const DeleteGroupAlertWidget({required this.group, Key? key})
      : super(key: key);

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);

    return AlertDialog(
      title: Text('Delete group'),
      content: RichText(
        text: TextSpan(style: theming.bodyText, children: <InlineSpan>[
          TextSpan(text: "Are you sure you want to delete the group "),
          TextSpan(style: theming.bodyTextBold, text: "${group.name}"),
          TextSpan(text: '?')
        ]),
      ),
      actions: [
        SimpleDialogOption(
          child: Text('No'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        SimpleDialogOption(
          child: Text('Yes'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  /// Show a dialog asking the user if they are sure if they want to delete
  /// the device.
  static Future<bool> showCustomDialog(BuildContext context,
      {required Group group}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteGroupAlertWidget(
            group: group,
          );
        }).then((value) {
      if (value is bool) {
        return value;
      }
      return false;
    });
  }
}
